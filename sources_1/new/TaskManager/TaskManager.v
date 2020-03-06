module TaskManager(
// Global Signals
input clk,
input rst,

//interface with SIMT
output Update_TM_SIMT,
output reg [2:0] WarpID_TM_SIMT,
output reg [7:0] AM_TM_SIMT,

//interface with Fetch
output UpdatePC_TM_PC,
output reg [2:0] WarpID_TM_PC,
output reg [31:0] StartingPC_TM_PC,

//interface with Issue Unit
input Exit_IB_RAU_TM,
input [2:0] Exit_WarpID_IB_RAU_TM,

//interface with Register File Allocation Unit
output Update_TM_RAU,
output [2:0] HWWarpID_TM_RAU,
output [7:0] SWWarpID_TM_RAU, // FIXME: interface with RAU vs OC?
output [2:0] Nreg_TM_RAU,
input Alloc_BusyBar_RAU_TM

);

endmodule