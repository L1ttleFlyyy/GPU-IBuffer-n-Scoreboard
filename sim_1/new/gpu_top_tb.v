`timescale 1ns/100ps

module testbench;

localparam tm_depth = 256;
localparam icache_depth = 1024;
localparam mem_depth = 256;
localparam cle_depth = mem_depth;
localparam shmem_depth = 256;

localparam mem_total_depth = mem_depth + shmem_depth;

localparam mem_addr_width = $clog2(mem_depth);
localparam addr_width = $clog2(mem_total_depth);

reg clk_tb;
reg rst_tb;
    
    // FileIO to TM
    
reg Wen_FIO_TM_tb;
reg [28:0] Din_FIO_TM_tb;
reg start_FIO_TM_tb;
reg clear_FIO_TM_tb;
wire finished_TM_FIO_tb;

    // FileIO to ICache
reg Wen_FIO_ICache_tb;
reg [9:0] Addr_FIO_ICache_tb;
reg [31:0] Din_FIO_ICache_tb;
wire [31:0] Dout_FIO_ICache_tb;

    // FileIO to MEM
reg Wen_FIO_MEM_tb;
reg [addr_width-1:0] Addr_FIO_MEM_tb;                    //default
reg [255:0] Din_FIO_MEM_tb;
wire [255:0] Dout_FIO_MEM_tb;
	
reg Wen_FIO_CLE_tb;
reg [4:0] Din_FIO_CLE_tb;
reg [mem_addr_width-1:0] Addr_FIO_CLE_tb;          //default

integer fd_TM, fd_ICache, fd_MEM, fd_CLE;

reg [31:0] temp_TM;
reg [31:0] temp_ICache;
reg [255:0] temp_MEM;
reg [7:0] temp_CLE;
 
reg [15:0] i_TM;
reg [15:0] i_ICache;
reg [15:0] i_MEM;
reg [15:0] i_CLE;

integer outfile, drawing;


initial
    begin:  CLOCK_GEN
    clk_tb = 0;
    forever
        begin
        # 5 clk_tb = ~clk_tb;
        end
    end

initial
    begin:rst
        rst_tb = 0;                     //low reset
        #20 rst_tb = 1;
    end

initial
    begin:  TM_init
        fd_TM = $fopen("TM_init.txt", "r");
        start_FIO_TM_tb = 0;
        clear_FIO_TM_tb = 0;
        wait(rst_tb);
        @ (posedge clk_tb);
        while(!$feof(fd_TM)) begin
            $fscanf(fd_TM, "%x\n", temp_TM);
            @ (posedge clk_tb);
            Wen_FIO_TM_tb = 1;
            Din_FIO_TM_tb = temp_TM[28:0];
        end
        @ (posedge clk_tb);
        Wen_FIO_TM_tb = 0;
        $fclose(fd_TM);
        wait(!Wen_FIO_ICache_tb);
        start_FIO_TM_tb = 1;
    end

initial
    begin:  I_CACHE_INIT
        // fd_ICache = $fopen("ICache_init_Mem_access3.txt", "r");
        // fd_ICache = $fopen("ICache_init_thread_div.txt", "r");
        // fd_ICache = $fopen("ICache_init_Circle_Drawing.txt", "r");
        // fd_ICache = $fopen("ICache_init_loop.txt", "r");
        fd_ICache = $fopen("ICache_init_matrix_mult.txt", "r");
        Wen_FIO_ICache_tb = 0;
        wait(rst_tb);
        @ (posedge clk_tb);
        Addr_FIO_ICache_tb = 0;
        Wen_FIO_ICache_tb = 1;
        while(!$feof(fd_ICache)) begin
            $fscanf(fd_ICache, "%x\n", temp_ICache);
            Din_FIO_ICache_tb = temp_ICache;
            @ (posedge clk_tb);
            Addr_FIO_ICache_tb = Addr_FIO_ICache_tb + 1;
        end
        Wen_FIO_ICache_tb = 0;
        $fclose(fd_ICache);
    end

initial
    begin:  MEM_INIT
        fd_MEM = $fopen("MEM_init.txt", "r");
        Wen_FIO_MEM_tb = 0;
        wait(rst_tb);
        @ (posedge clk_tb);
        Addr_FIO_MEM_tb = 0;
        Wen_FIO_MEM_tb = 1;
        while(!$feof(fd_MEM)) begin
            $fscanf(fd_MEM, "%x\n", temp_MEM);
            Din_FIO_MEM_tb = temp_MEM;
            @ (posedge clk_tb);
            Addr_FIO_MEM_tb = Addr_FIO_MEM_tb + 1;
        end
        Wen_FIO_MEM_tb = 0;
        $fclose(fd_MEM);
    end

initial
    begin:  CLE_INIT
        fd_CLE = $fopen("CLE_init.txt", "r");
        Wen_FIO_CLE_tb = 0;
        wait(rst_tb);
        @ (posedge clk_tb);
        Addr_FIO_CLE_tb = 0;
        Wen_FIO_CLE_tb = 1;
        while(!$feof(fd_CLE)) begin
            $fscanf(fd_CLE, "%x\n", temp_CLE);
            Din_FIO_CLE_tb = temp_CLE[4:0];
            @ (posedge clk_tb);
            Addr_FIO_CLE_tb = Addr_FIO_CLE_tb + 1;
        end
        Wen_FIO_CLE_tb = 0;
        $fclose(fd_CLE);
    end

initial
    begin:  DUMP_MEM
        wait (~Wen_FIO_MEM_tb);
        $display("All BRAMs initialized");
        wait (finished_TM_FIO_tb);
        $display("Execution finished, now dumping data");
        outfile = $fopen("MEM_dump.txt", "w");
        drawing = $fopen("MEM_draw.txt", "w");
        for(i_MEM = 0; i_MEM <= 96; i_MEM = i_MEM + 1) begin
            @(posedge clk_tb)
            Addr_FIO_MEM_tb = i_MEM;
            if (i_MEM > 0) begin
                $fwrite(outfile,"%x %x %x %x %x %x %x %x\n", Dout_FIO_MEM_tb[255:224], Dout_FIO_MEM_tb[223:192],
                    Dout_FIO_MEM_tb[191:160], Dout_FIO_MEM_tb[159:128],
                    Dout_FIO_MEM_tb[127:96], Dout_FIO_MEM_tb[95:64],
                    Dout_FIO_MEM_tb[63:32], Dout_FIO_MEM_tb[31:0]);
            end
            if (i_MEM > 0) begin
                if (i_MEM % 2) begin // odd warpID
                    $fwrite(drawing,"%x %x %x %x %x %x %x %x ", Dout_FIO_MEM_tb[31:0], Dout_FIO_MEM_tb[63:32], 
                        Dout_FIO_MEM_tb[95:64], Dout_FIO_MEM_tb[127:96], 
                        Dout_FIO_MEM_tb[159:128], Dout_FIO_MEM_tb[191:160], 
                        Dout_FIO_MEM_tb[223:192], Dout_FIO_MEM_tb[255:224]);
                end else begin // even warpID
                    $fwrite(drawing,"%x %x %x %x %x %x %x %x\n", Dout_FIO_MEM_tb[31:0], Dout_FIO_MEM_tb[63:32], 
                        Dout_FIO_MEM_tb[95:64], Dout_FIO_MEM_tb[127:96], 
                        Dout_FIO_MEM_tb[159:128], Dout_FIO_MEM_tb[191:160], 
                        Dout_FIO_MEM_tb[223:192], Dout_FIO_MEM_tb[255:224]);
                end
            end
        end
        $fclose(drawing);
        $fclose(outfile);
        $display("Dump finished");
        $finish;
    end


gpu_top_checking #(
	.mem_size(mem_depth),
	.shmem_size(shmem_depth),
    .cache_size(64)
)DUT(
.clk(clk_tb),
.rst(rst_tb),
    
    // FileIO to TM
    
.Wen_FIO_TM(Wen_FIO_TM_tb),
.Din_FIO_TM(Din_FIO_TM_tb),
.start_FIO_TM(start_FIO_TM_tb),
.clear_FIO_TM(clear_FIO_TM_tb),
.finished_TM_FIO(finished_TM_FIO_tb),

    // FileIO to ICache
.Wen_FIO_ICache(Wen_FIO_ICache_tb),
.Addr_FIO_ICache(Addr_FIO_ICache_tb),
.Din_FIO_ICache(Din_FIO_ICache_tb),
.Dout_FIO_ICache(Dout_FIO_ICache_tb),

    // FileIO to MEM
.Wen_FIO_MEM(Wen_FIO_MEM_tb),
.Addr_FIO_MEM(Addr_FIO_MEM_tb),
.Din_FIO_MEM(Din_FIO_MEM_tb),
.Dout_FIO_MEM(Dout_FIO_MEM_tb),
	
.Wen_FIO_CLE(Wen_FIO_CLE_tb),
.Din_FIO_CLE(Din_FIO_CLE_tb),
.Addr_FIO_CLE(Addr_FIO_CLE_tb)

);



endmodule