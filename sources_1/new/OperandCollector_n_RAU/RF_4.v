`timescale 1ns / 100ps

module RegisterFile(
    input wire clk,

    input wire [7:0] RF_WR_MASK,
    input wire [2:0] RF_Addr_0,
    input wire [2:0] RF_Addr_1,
    input wire [2:0] RF_Addr_2,
    input wire [2:0] RF_Addr_3,

    input wire [3:0] ocid_out_0,
    input wire [3:0] ocid_out_1,
    input wire [3:0] ocid_out_2,
    input wire [3:0] ocid_out_3,

    input wire RF_WR_0,
    input wire RF_WR_1,
    input wire RF_WR_2,
    input wire RF_WR_3,

    input wire same_0,
    input wire same_1,
    input wire same_2,
    input wire same_3,

    input wire [255:0] WriteData_0,
    input wire [255:0] WriteData_1,
    input wire [255:0] WriteData_2,
    input wire [255:0] WriteData_3,

    output wire [255:0] DataOut_0,
    output wire [255:0] DataOut_1,
    output wire [255:0] DataOut_2,
    output wire [255:0] DataOut_3,//不能写wire？

    output reg same_OC_0,
    output reg same_OC_1,
    output reg same_OC_2,
    output reg same_OC_3,


    output reg [3:0] ocid_0,
    output reg [3:0] ocid_1,
    output reg [3:0] ocid_2,
    output reg [3:0] ocid_3
);

wire [7:0] RF_WR_MASK_0 = RF_WR_0 ? RF_WR_MASK : 8'b00000000;
wire [7:0] RF_WR_MASK_1 = RF_WR_1 ? RF_WR_MASK : 8'b00000000;
wire [7:0] RF_WR_MASK_2 = RF_WR_2 ? RF_WR_MASK : 8'b00000000;
wire [7:0] RF_WR_MASK_3 = RF_WR_3 ? RF_WR_MASK : 8'b00000000;



always @ (posedge clk)
begin
    ocid_0 <= ocid_out_0;
    ocid_1 <= ocid_out_1;
    ocid_2 <= ocid_out_2;
    ocid_3 <= ocid_out_3;
    same_OC_0 <= same_0;
    same_OC_1 <= same_1;
    same_OC_2 <= same_2;
    same_OC_3 <= same_3;

    
end

BRAM_MASK RF_0(
    .clk(clk),


    .RF_WR_MASK(RF_WR_MASK_0),
    .RF_Addr(RF_Addr_0),
    .WriteData(WriteData_0),

    .DataOut(DataOut_0)
);

BRAM_MASK RF_1(
    .clk(clk),


    .RF_WR_MASK(RF_WR_MASK_1),
    .RF_Addr(RF_Addr_1),
    .WriteData(WriteData_1),

    .DataOut(DataOut_1)
);
BRAM_MASK RF_2(
    .clk(clk),


    .RF_WR_MASK(RF_WR_MASK_2),
    .RF_Addr(RF_Addr_2),
    .WriteData(WriteData_2),

    .DataOut(DataOut_2)
);
BRAM_MASK RF_3(
    .clk(clk),


    .RF_WR_MASK(RF_WR_MASK_3),
    .RF_Addr(RF_Addr_3),
    .WriteData(WriteData_3),

    .DataOut(DataOut_3)
);
endmodule