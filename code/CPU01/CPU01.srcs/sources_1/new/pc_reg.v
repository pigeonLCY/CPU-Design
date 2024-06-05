//pc
`include "defines.v"
module pc_reg( //���������ʱ��
    clk,//ʱ���ź�
    rst,//��λ�ź�
    pc, //pc
    ce  //ָ��洢��ʹ��
);

input wire clk;
input wire rst;
output reg[`InstAddrBus]    pc;
output reg                  ce;

//ʱ���·
always @ (posedge clk) begin
		if (rst == `RstEnable) begin //��λ
			ce <= `ChipDisable; //����ָ��洢��
		end else begin
			ce <= `ChipEnable;
		end
	end
//ʱ���·
always @ (posedge clk) begin
    if (ce == `ChipDisable) begin //����ָ��洢��ʱ
			pc <= `ZeroWord;  //pc=0
		end else begin  
	 		pc <= pc + 4'h4; //����ָ����һ��ָ��pc+=4
		end
end
endmodule
