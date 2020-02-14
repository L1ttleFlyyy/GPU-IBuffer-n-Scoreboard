module TaskManager(
// Global Signals
input clk,
input rst,

//interface with SIMT
output Update_TM_SIMT,
output reg [2:0] WarpID_TM_SIMT,
output reg [7:0] AM_TM_SIMT,

//interface with Fetch
output Update_TM_IF,
output reg [2:0] WarpID_TM_IF,
output reg [9:0] PC_TM_IF,

//interface with Issue Unit
input Exit_IU_SIMT,
input [2:0] WarpID_IU_TM,

//interface with Register File Allocation Unit
input alloc_busyBar_RAU_TM,
output alloc_TM_RAU,
output [2:0] reg_TM_RAU,
output [2:0] WarpID_TM_RAU,

//interface with Operand Collector
output Update_TM_OC,
output [2:0] HWwarpID_TM_OC,
output [7:0] SWwarpID_TM_OC

);

endmodule