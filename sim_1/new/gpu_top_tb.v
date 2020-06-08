`timescale 1ns/100ps

module testbench;

localparam tm_depth = 256;
localparam icache_depth = 1024;
localparam mem_depth = 256;
localparam emu_depth = mem_depth;
localparam shmem_depth = 256;

localparam mem_total_depth = mem_depth + shmem_depth;

localparam mem_addr_width = $clog2(mem_depth);
localparam addr_width = $clog2(mem_total_depth);

reg clk_tb;
reg rst_tb;
    
    // FileIO to TM
    
reg Write_Enable_FIO_TM_tb;
reg [28:0] Write_Data_FIO_TM_tb;
reg start_FIO_TM_tb;
reg clear_FIO_TM_tb;
wire finished_TM_FIO_tb;

    // FileIO to ICache
reg FileIO_Wen_ICache_tb;
reg [9:0] FileIO_Addr_ICache_tb;
reg [31:0] FileIO_Din_ICache_tb;
wire [31:0] FileIO_Dout_ICache_tb;

    // FileIO to MEM
reg FIO_MEMWRITE_tb;
reg [addr_width-1:0] FIO_ADDR_tb;                    //default
reg [255:0] FIO_WRITE_DATA_tb;
wire [255:0] FIO_READ_DATA_tb;
	
reg FIO_CACHE_LAT_WRITE_tb;
reg [4:0] FIO_CACHE_LAT_VALUE_tb;
reg [mem_addr_width-1:0] FIO_CACHE_MEM_ADDR_tb;          //default

integer fd_TM, fd_ICache, fd_MEM, fd_EMU;

reg [31:0] temp_TM;
reg [31:0] temp_ICache;
reg [255:0] temp_MEM;
reg [7:0] temp_EMU;
 
reg [15:0] i_TM;
reg [15:0] i_ICache;
reg [15:0] i_MEM;
reg [15:0] i_EMU;

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
            Write_Enable_FIO_TM_tb = 1;
            Write_Data_FIO_TM_tb = temp_TM[28:0];
        end
        @ (posedge clk_tb);
        Write_Enable_FIO_TM_tb = 0;
        $fclose(fd_TM);
        wait(!FileIO_Wen_ICache_tb);
        start_FIO_TM_tb = 1;
    end

initial
    begin:  I_CACHE_INIT
        fd_ICache = $fopen("ICache_init_thread_div.txt", "r");
        // fd_ICache = $fopen("ICache_init_Circle_Drawing.txt", "r");
        FileIO_Wen_ICache_tb = 0;
        wait(rst_tb);
        @ (posedge clk_tb);
        FileIO_Addr_ICache_tb = 0;
        FileIO_Wen_ICache_tb = 1;
        while(!$feof(fd_ICache)) begin
            $fscanf(fd_ICache, "%x\n", temp_ICache);
            FileIO_Din_ICache_tb = temp_ICache;
            @ (posedge clk_tb);
            FileIO_Addr_ICache_tb = FileIO_Addr_ICache_tb + 1;
        end
        FileIO_Wen_ICache_tb = 0;
        $fclose(fd_ICache);
    end

initial
    begin:  MEM_INIT
        fd_MEM = $fopen("MEM_init.txt", "r");
        FIO_MEMWRITE_tb = 0;
        wait(rst_tb);
        @ (posedge clk_tb);
        FIO_ADDR_tb = 0;
        FIO_MEMWRITE_tb = 1;
        while(!$feof(fd_MEM)) begin
            $fscanf(fd_MEM, "%x\n", temp_MEM);
            FIO_WRITE_DATA_tb = temp_MEM;
            @ (posedge clk_tb);
            FIO_ADDR_tb = FIO_ADDR_tb + 1;
        end
        FIO_MEMWRITE_tb = 0;
        $fclose(fd_MEM);
    end

initial
    begin:  EMU_INIT
        fd_EMU = $fopen("EMU_init.txt", "r");
        FIO_CACHE_LAT_WRITE_tb = 0;
        wait(rst_tb);
        @ (posedge clk_tb);
        FIO_CACHE_MEM_ADDR_tb = 0;
        FIO_CACHE_LAT_WRITE_tb = 1;
        while(!$feof(fd_EMU)) begin
            $fscanf(fd_EMU, "%x\n", temp_EMU);
            FIO_CACHE_LAT_VALUE_tb = temp_EMU;
            @ (posedge clk_tb);
            FIO_CACHE_MEM_ADDR_tb = FIO_CACHE_MEM_ADDR_tb + 1;
        end
        FIO_CACHE_LAT_WRITE_tb = 0;
        $fclose(fd_EMU);
    end

initial
    begin:  DUMP_MEM
        wait (~FIO_MEMWRITE_tb);
        $display("All BRAMs initialized");
        wait (finished_TM_FIO_tb);
        $display("Execution finished, now dumping data");
        outfile = $fopen("MEM_dump.txt", "w");
        drawing = $fopen("MEM_draw.txt", "w");
        for(i_MEM = 0; i_MEM <= 32; i_MEM = i_MEM + 1) begin
            @(posedge clk_tb)
            FIO_ADDR_tb = i_MEM;
            if (i_MEM > 0) begin
                $fwrite(outfile,"%x %x %x %x %x %x %x %x\n", FIO_READ_DATA_tb[255:224], FIO_READ_DATA_tb[223:192],
                    FIO_READ_DATA_tb[191:160], FIO_READ_DATA_tb[159:128],
                    FIO_READ_DATA_tb[127:96], FIO_READ_DATA_tb[95:64],
                    FIO_READ_DATA_tb[63:32], FIO_READ_DATA_tb[31:0]);
            end
            if (i_MEM > 0) begin
                if (i_MEM % 2) begin // odd warpID
                    $fwrite(drawing,"%x %x %x %x %x %x %x %x ", FIO_READ_DATA_tb[31:0], FIO_READ_DATA_tb[63:32], 
                        FIO_READ_DATA_tb[95:64], FIO_READ_DATA_tb[127:96], 
                        FIO_READ_DATA_tb[159:128], FIO_READ_DATA_tb[191:160], 
                        FIO_READ_DATA_tb[223:192], FIO_READ_DATA_tb[255:224]);
                end else begin // even warpID
                    $fwrite(drawing,"%x %x %x %x %x %x %x %x\n", FIO_READ_DATA_tb[31:0], FIO_READ_DATA_tb[63:32], 
                        FIO_READ_DATA_tb[95:64], FIO_READ_DATA_tb[127:96], 
                        FIO_READ_DATA_tb[159:128], FIO_READ_DATA_tb[191:160], 
                        FIO_READ_DATA_tb[223:192], FIO_READ_DATA_tb[255:224]);
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
    
.Write_Enable_FIO_TM(Write_Enable_FIO_TM_tb),
.Write_Data_FIO_TM(Write_Data_FIO_TM_tb),
.start_FIO_TM(start_FIO_TM_tb),
.clear_FIO_TM(clear_FIO_TM_tb),
.finished_TM_FIO(finished_TM_FIO_tb),

    // FileIO to ICache
.FileIO_Wen_ICache(FileIO_Wen_ICache_tb),
.FileIO_Addr_ICache(FileIO_Addr_ICache_tb),
.FileIO_Din_ICache(FileIO_Din_ICache_tb),
.FileIO_Dout_ICache(FileIO_Dout_ICache_tb),

    // FileIO to MEM
.FIO_MEMWRITE(FIO_MEMWRITE_tb),
.FIO_ADDR(FIO_ADDR_tb),
.FIO_WRITE_DATA(FIO_WRITE_DATA_tb),
.FIO_READ_DATA(FIO_READ_DATA_tb),
	
.FIO_CACHE_LAT_WRITE(FIO_CACHE_LAT_WRITE_tb),
.FIO_CACHE_LAT_VALUE(FIO_CACHE_LAT_VALUE_tb),
.FIO_CACHE_MEM_ADDR(FIO_CACHE_MEM_ADDR_tb)

);



endmodule