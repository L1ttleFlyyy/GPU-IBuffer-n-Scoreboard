`timescale 1ns/100ps

module testbench;

localparam tm_depth = 256;
localparam icache_depth = 4096;
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
reg [11:0] FileIO_Addr_ICache_tb;
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

reg [31:0] temp_ICache [0:icache_depth-1];
reg [255:0] temp_MEM [0:mem_total_depth-1];
reg [7:0] temp_EMU [0:emu_depth-1];
reg [31:0] temp_TM [0:tm_depth-1];

reg [255:0] Read_temp;
 
reg [15:0] i_ICache;
reg [15:0] i_MEM;
reg [15:0] i_EMU;
reg [15:0] i_TM;



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

initial                             //MEM_INIT
    begin
    $readmemh("TM_init.txt", temp_TM);
    $readmemh("ICache_init_new.txt", temp_ICache);
    $readmemh("MEM_init.txt", temp_MEM);
    $readmemh("EMU_init.txt", temp_EMU);
    end

initial
    begin:  TM_INIT
        @ (posedge clk_tb);
        clear_FIO_TM_tb = 0;
        wait(rst_tb);
        for(i_TM = 0; i_TM < tm_depth; i_TM = i_TM+1)
        begin
            @ (posedge clk_tb);
            Write_Enable_FIO_TM_tb = 1;
            Write_Data_FIO_TM_tb = temp_TM[i_TM][28:0];
        end
        @ (posedge clk_tb);
        Write_Enable_FIO_TM_tb = 0;
    end

initial
    begin:  I_CACHE_INIT
        wait(rst_tb);
        start_FIO_TM_tb = 0;
        FileIO_Wen_ICache_tb = 1;
        for(i_ICache = 0; i_ICache < icache_depth; i_ICache = i_ICache+1)
            begin
                @ (posedge clk_tb);
                FileIO_Addr_ICache_tb = i_ICache;
                FileIO_Din_ICache_tb = temp_ICache[i_ICache];
            end
        @ (posedge clk_tb);
        FileIO_Wen_ICache_tb = 0;
        start_FIO_TM_tb = 1;
    end

initial
    begin:  MEM_INIT
        wait(rst_tb);
        FIO_MEMWRITE_tb = 1;
        for(i_MEM = 0; i_MEM < mem_total_depth; i_MEM = i_MEM+1)
            begin
                @ (posedge clk_tb);
                FIO_ADDR_tb = i_MEM;
                FIO_WRITE_DATA_tb = temp_MEM[i_MEM];
            end
        @ (posedge clk_tb);
        FIO_MEMWRITE_tb = 0;
    end

initial
    begin:  EMU_INIT
        wait(rst_tb);
        FIO_CACHE_LAT_WRITE_tb = 1;
        for(i_EMU = 0; i_EMU < emu_depth; i_EMU = i_EMU+1)
            begin
                @ (posedge clk_tb);
                FIO_CACHE_MEM_ADDR_tb = i_EMU;
                FIO_CACHE_LAT_VALUE_tb = temp_EMU[i_EMU][4:0];
            end
        @ (posedge clk_tb);
        FIO_CACHE_LAT_WRITE_tb = 0;
        
    end

initial
    begin:  DUMP_MEM
        wait (~FIO_MEMWRITE_tb);
            $display("All BRAMs initialized");
        wait (finished_TM_FIO_tb);
            $display("Execution finished, now dumping data");
            // for(i_MEM = 0; i_MEM <= 255; i_MEM = i_MEM+1)
            //     begin
            //         @(posedge clk_tb)
            //         FIO_ADDR_tb = i_MEM;
            //         Read_temp = FIO_READ_DATA_tb;
            //         $display ("Addr before 2 clk = %d, Data = %b", i_MEM, Read_temp);
            //     end
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