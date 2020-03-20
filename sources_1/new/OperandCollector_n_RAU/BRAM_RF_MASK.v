module BRAM_MASK(
    input wire clk,


    input wire [7:0] RF_WR_MASK,
    input wire [2:0] RF_Addr,
    input wire [255:0] WriteData,
    
    output wire [255:0] DataOut
);

genvar i;
generate

for (i = 0; i < 8; i = i + 1) begin: RF_thread
    BRAM_SinglePort #(
    .OREG(0),
    .DATA(32),
    .ADDR(3)
    ) RF_MASK (

    // Port A
    .a_clk(clk),
    .a_wr(RF_WR_MASK[i]),
    .a_addr(RF_Addr),
    .a_din(WriteData[32 * i + 31: 32 * i]),
    .a_dout(DataOut[32 * i + 31: 32 * i])
);
end

endgenerate

endmodule