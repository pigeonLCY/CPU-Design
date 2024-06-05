//pc
`include "defines.v"
module pc_reg( //程序计数计时器
    clk,//时钟信号
    rst,//复位信号
    pc, //pc
    ce  //指令存储器使能
);

input wire clk;
input wire rst;
output reg[`InstAddrBus]    pc;
output reg                  ce;

//时序电路
always @ (posedge clk) begin
		if (rst == `RstEnable) begin //复位
			ce <= `ChipDisable; //禁用指令存储器
		end else begin
			ce <= `ChipEnable;
		end
	end
//时序电路
always @ (posedge clk) begin
    if (ce == `ChipDisable) begin //禁用指令存储器时
			pc <= `ZeroWord;  //pc=0
		end else begin  
	 		pc <= pc + 4'h4; //否则指向下一条指令pc+=4
		end
end
endmodule
