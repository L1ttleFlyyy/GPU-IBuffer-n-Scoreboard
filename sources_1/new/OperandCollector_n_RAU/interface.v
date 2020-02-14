module RAU 
(
    input wire rst,
    input wire clk,

    input wire [2:0]Exit_WarpID_IB_RAU,
    input wire Exit_IB_RAU,
    input wire TM_RAU_HWWarp,
    input wire TM_RAU_AlloEN,
    input wire TM_RAU_Nreq,
    input wire TM_RAU_SWWarp,

    output reg RAU_TM_Available
);
endmodule

module Parallel_control
(
    input wire [31:0] IU_OC_Instr,
    input wire oc_0_empty, oc_1_empty, oc_2_empty, oc_3_empty,
    input wire [2:0] IU_OC_HWWarp,
    input wire clk, rst,

    output reg [2:0] rowid_a, [1:0] bankid_a,
           reg [2:0] rowid_b, [1:0] bankid_b,
           reg [1:0] IU_OC_ocid,
    output wire ReqFIFO_2op_EN

);
endmodule

module OC_collector_unit 
#(
parameter ocid = 0
)
(
WE, RE, valid, bypass_pyld_in,
c_0_reg_id_in,c_1_reg_id_in,
bk_0_data, bk_0_vld, bk_0_ocid, bk_0_bz,
bk_1_data, bk_1_vld, bk_1_ocid, bk_1_bz,
bk_2_data, bk_2_vld, bk_2_ocid, bk_2_bz,
bk_3_data, bk_3_vld, bk_3_ocid, bk_3_bz,
clk,rst, // inputs
RDY, bypass_pyld, oc_0_data, oc_1_data   //outputs
);
endmodule

module  RF_Controler
(
    input wire ReqFIFO_2op_EN,
    input wire [2:0] rowid_a, rowid_b,
    input wire [1:0] ocid,
    input wire CDB_RF_RegWrite,
    input wire CDB_RF_WriteAddr,

    output reg [2:0] RF_Addr,
    output reg [1:0] ocid_out,
    output wire RF_WR,
    output wire bank_valid
);
endmodule
