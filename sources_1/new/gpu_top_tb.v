`timescale 1ns/100ps

module testbench;
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
reg FIO_ADDR_tb;                    //default
reg [255:0] FIO_WRITE_DATA_tb;
wire [255:0] FIO_READ_DATA_tb;
	
reg FIO_CACHE_LAT_WRITE_tb;
reg [4:0] FIO_CACHE_LAT_VALUE_tb;
reg FIO_CACHE_MEM_ADDR_tb;          //default

reg [31:0] temp_ICache [0:4095];
reg [255:0] temp_MEM [0:255];
reg [4:0] temp_EMU [0:511];
reg [28:0] temp_TM;

reg [255:0] Read_temp;
 
reg [11:0] i_ICache;
reg [7:0] i_MEM;
reg [8:0] i_EMU;



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
        #2 rst_tb = 1;
    end

initial                             //MEM_INIT
    begin
    $readmemb("TM_init.txt", temp_TM);
    $readmemb("ICache_init.txt", temp_ICache);
    $readmemb("MEM_init.txt", temp_MEM);
    $readmemb("EMU_init.txt", temp_EMU);
    end

initial
    begin:  TM_INIT
        Write_Enable_FIO_TM_tb = 1;
        @ (posedge clk_tb);
        Write_Data_FIO_TM_tb = temp_TM;
        @ (posedge clk_tb);
        Write_Enable_FIO_TM_tb = 0;
    end

initial
    begin:  I_CACHE_INIT
        start_FIO_TM_tb = 0;
        FileIO_Wen_ICache_tb = 1;
        for(i_ICache = 0; i_ICache <= 4095; i_ICache = i_ICache+1)
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
        FIO_MEMWRITE_tb = 1;
        for(i_MEM = 0; i_MEM <= 255; i_MEM = i_MEM+1)
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
        
        FIO_CACHE_LAT_WRITE_tb = 1;
        for(i_EMU = 0; i_EMU <= 511; i_EMU = i_EMU+1)
            begin
                @ (posedge clk_tb);
                FIO_CACHE_MEM_ADDR_tb = i_EMU;
                FIO_CACHE_LAT_VALUE_tb = temp_EMU[i_MEM];
            end
        @ (posedge clk_tb);
        FIO_CACHE_LAT_WRITE_tb = 0;
        
    end

initial
    begin:  DUMP_MEM
        wait (finished_TM_FIO_tb);
            for(i_MEM = 0; i_MEM <= 255; i_MEM = i_MEM+1)
                @(posedge clk_tb)
                FIO_ADDR_tb = i_MEM;
                Read_temp = FIO_READ_DATA_tb;
                $display ("Addr before 2 clk = %d, Data = %b", i_MEM, Read_temp)
    end


gpu_top_checking DUT(
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