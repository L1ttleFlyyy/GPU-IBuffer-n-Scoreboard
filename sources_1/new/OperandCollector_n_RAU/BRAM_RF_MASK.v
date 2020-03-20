module BRAM_MASK(
    input wire clk,
    input wire rst,

    input wire [7:0] RF_WR_MASK,
    input wire [2:0] RF_Addr,
    input wire RF_WR,
    input wire [255:0] WriteData,

    output wire [255:0] DataOut
);




Inferable_BRAM #(
    .OREG(0),
    .DATA(32),
    .ADDR(3)
)
RF_MASK_0(

    // Port A
    .a_clk(clk),
    .a_wr(RF_WR_MASK[0]),
    .a_addr(RF_Addr),
    .a_din(WriteData[31:0]),
    .a_dout(DataOut[31:0]),
     
    // Port B
    .b_clk(clk),
    .b_wr(RF_WR_MASK[0]),
    .b_addr(RF_Addr),
    .b_din(WriteData[31:0]),
    .b_dout()
);

Inferable_BRAM #(
    .OREG(0),
    .DATA(32),
    .ADDR(3)
)
RF_MASK_1(

    // Port A
    .a_clk(clk),
    .a_wr(RF_WR_MASK[1]),
    .a_addr(RF_Addr),
    .a_din(WriteData[63:32]),
    .a_dout(DataOut[63:32]),
     
    // Port B
    .b_clk(clk),
    .b_wr(RF_WR_MASK[1]),
    .b_addr(RF_Addr),
    .b_din(WriteData[63:32]),
    .b_dout()
);
Inferable_BRAM #(
    .OREG(0),
    .DATA(32),
    .ADDR(3)
)
RF_MASK_2(

    // Port A
    .a_clk(clk),
    .a_wr(RF_WR_MASK[2]),
    .a_addr(RF_Addr),
    .a_din(WriteData[95:64]),
    .a_dout(DataOut[95:64]),
     
    // Port B
    .b_clk(clk),
    .b_wr(RF_WR_MASK[2]),
    .b_addr(RF_Addr),
    .b_din(WriteData[95:64]),
    .b_dout()
);
Inferable_BRAM #(
    .OREG(0),
    .DATA(32),
    .ADDR(3)
)
RF_MASK_3(

    // Port A
    .a_clk(clk),
    .a_wr(RF_WR_MASK[3]),
    .a_addr(RF_Addr),
    .a_din(WriteData[127:96]),
    .a_dout(DataOut[127:96]),
     
    // Port B
    .b_clk(clk),
    .b_wr(RF_WR_MASK[3]),
    .b_addr(RF_Addr),
    .b_din(WriteData[127:96]),
    .b_dout()
);
Inferable_BRAM #(
    .OREG(0),
    .DATA(32),
    .ADDR(3)
)
RF_MASK_4(

    // Port A
    .a_clk(clk),
    .a_wr(RF_WR_MASK[4]),
    .a_addr(RF_Addr),
    .a_din(WriteData[159:128]),
    .a_dout(DataOut[159:128]),
     
    // Port B
    .b_clk(clk),
    .b_wr(RF_WR_MASK[4]),
    .b_addr(RF_Addr),
    .b_din(WriteData[159:128]),
    .b_dout()
);
Inferable_BRAM #(
    .OREG(0),
    .DATA(32),
    .ADDR(3)
)
RF_MASK_5(

    // Port A
    .a_clk(clk),
    .a_wr(RF_WR_MASK[5]),
    .a_addr(RF_Addr),
    .a_din(WriteData[191:160]),
    .a_dout(DataOut[191:160]),
     
    // Port B
    .b_clk(clk),
    .b_wr(RF_WR_MASK[5]),
    .b_addr(RF_Addr),
    .b_din(WriteData[191:160]),
    .b_dout()
);
Inferable_BRAM #(
    .OREG(0),
    .DATA(32),
    .ADDR(3)
)
RF_MASK_6(

    // Port A
    .a_clk(clk),
    .a_wr(RF_WR_MASK[6]),
    .a_addr(RF_Addr),
    .a_din(WriteData[223:192]),
    .a_dout(DataOut[223:192]),
     
    // Port B
    .b_clk(clk),
    .b_wr(RF_WR_MASK[6]),
    .b_addr(RF_Addr),
    .b_din(WriteData[223:192]),
    .b_dout()
);
Inferable_BRAM #(
    .OREG(0),
    .DATA(32),
    .ADDR(3)
)
RF_MASK_7(

    // Port A
    .a_clk(clk),
    .a_wr(RF_WR_MASK[7]),
    .a_addr(RF_Addr),
    .a_din(WriteData[255:224]),
    .a_dout(DataOut[255:224]),
     
    // Port B
    .b_clk(clk),
    .b_wr(RF_WR_MASK[7]),
    .b_addr(RF_Addr),
    .b_din(WriteData[255:224]),
    .b_dout()
);

endmodule