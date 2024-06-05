//hilo �Ĵ���

`include "defines.v"

module hilo_reg(
    //��������
    clk,    //ʱ���ź�
    rst,    //��λ�ź�
    we,     //дʹ��
    hi_i,   //���� hi
    lo_i,   //���� lo
    hi_o,   //���hi
    lo_o    //���lo
	
);
//��������
input wire  clk;    //ʱ���ź�
input wire  rst;     //��λ�ź�
input wire          we;     //дʹ��
input wire[`RegBus] hi_i;   //���� hi
input wire[`RegBus] lo_i;   //���� lo
output reg[`RegBus] hi_o;   //���hi
output reg[`RegBus] lo_o;   //���lo


//ʱ���߼���·
always @ (posedge clk) begin
    if (rst == `RstEnable) begin //��λ
                hi_o <= `ZeroWord;
                lo_o <= `ZeroWord;
    end else if((we == `WriteEnable)) begin //���������
                hi_o <= hi_i;
                lo_o <= lo_i;
    end
end

endmodule