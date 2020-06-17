`timescale 1ns / 100ps
//ReqFIFO:  O.C:    Warp;      ----fetching data request;
//                  Logic Reg;
//                  O.C ID;
//RF a_wr,b_wr to conrtol read/write; 1->write 0->read;
//          CDB:    RegWrite;   ----Disable FIFO
//Output:   ReadAddr;
//          WriteAddr;

module  ReqFIFO (
    input wire rst,
    input wire clk,

    input wire ReqFIFO_2op_EN,
    input wire Src1_Valid,
    input wire Src2_Valid,
    input wire [2:0] Src1_Phy_Row_ID, Src2_Phy_Row_ID,
    input wire [2:0] Src1_OCID_RAU_OC,
    input wire [2:0] Src2_OCID_RAU_OC,
    input wire RF_Read_Valid,
    input wire RF_Write_Valid,
    input wire [2:0] WriteRow,
    input wire [255:0] Data_CDB,
    input wire ReqFIFO_Same,

    output wire [2:0] RF_Addr,
    output wire [3:0] ocid_out,
    output wire RF_WR,//直接assign？？

    output wire [255:0] WriteData,
    output wire same
);



//定义fifo
wire rp_en;
reg [6:0] ReqFIFO [7:0];
reg [4:0] Rp, Wp, Wp_p1;//2 read req
wire [3:0] depth = Wp - Rp;
wire Full = (depth == 4'b1000);
wire [2:0] Rp_ind = Rp[2:0];
wire [2:0] Wp_ind = Wp[2:0];
wire [2:0] Wp_p1_ind = Wp_p1[2:0];
//wire Rp_EN, Wp_EN, Wp_p1_EN;



//ReqFIFO
always @ (posedge clk)
begin
    if (rst == 1'b0) begin
        Rp <= 4'b0000;
        Wp <= 4'b0000;
        Wp_p1 <= 4'b0001;//hold for two source operands falls into same bank;
    end else begin
    if (RF_Read_Valid == 1) begin
        if (!Full) begin   
                if ((ReqFIFO_2op_EN == 1) & (ReqFIFO_Same == 1'b0) & (depth < 7)) begin
                    ReqFIFO[Wp_ind] <= {1'b0, Src1_OCID_RAU_OC, Src1_Phy_Row_ID};
                    ReqFIFO[Wp_p1_ind] <= {1'b0, Src2_OCID_RAU_OC, Src2_Phy_Row_ID};
                    Wp <= Wp + 2;
                    Wp_p1 <= Wp_p1 + 2;
                end else if (((ReqFIFO_2op_EN == 1'b0) | (ReqFIFO_Same == 1'b1))) begin
                    if (Src1_Valid) begin
                        ReqFIFO[Wp_ind] <= {(ReqFIFO_Same == 1'b1),Src1_OCID_RAU_OC, Src1_Phy_Row_ID};//分配到不同的bank
                        Wp <= Wp + 1;
                        Wp_p1 <= Wp_p1 + 1;
                    end else if (Src2_Valid) begin
                        ReqFIFO[Wp_ind] <= {(ReqFIFO_Same == 1'b1),Src2_OCID_RAU_OC, Src2_Phy_Row_ID};//分配到不同的bank
                        Wp <= Wp + 1;
                        Wp_p1 <= Wp_p1 + 1;
                    end
                end
            end
        end
        
    if (rp_en) begin
        Rp <= Rp + 1;
    end

    end

end

assign rp_en = (depth != 0) && !RF_Write_Valid;
assign RF_Addr = RF_Write_Valid ? WriteRow: ReqFIFO[Rp_ind][2:0];
assign ocid_out = {rp_en, ReqFIFO[Rp_ind][5:3]};//写assign还是在里面
assign RF_WR = RF_Write_Valid;
assign same = (ReqFIFO[Rp_ind][6]);

assign WriteData = Data_CDB;

endmodule

//check special registers

//需要提前write addr LUT

//FIFO_FULL?