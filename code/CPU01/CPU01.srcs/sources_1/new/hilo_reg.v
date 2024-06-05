//hilo 寄存器

`include "defines.v"

module hilo_reg(
    //定义名称
    clk,    //时钟信号
    rst,    //复位信号
    we,     //写使能
    hi_i,   //输入 hi
    lo_i,   //输入 lo
    hi_o,   //输出hi
    lo_o    //输出lo
	
);
//定义类型
input wire  clk;    //时钟信号
input wire  rst;     //复位信号
input wire          we;     //写使能
input wire[`RegBus] hi_i;   //输入 hi
input wire[`RegBus] lo_i;   //输入 lo
output reg[`RegBus] hi_o;   //输出hi
output reg[`RegBus] lo_o;   //输出lo


//时序逻辑电路
always @ (posedge clk) begin
    if (rst == `RstEnable) begin //复位
                hi_o <= `ZeroWord;
                lo_o <= `ZeroWord;
    end else if((we == `WriteEnable)) begin //将数据输出
                hi_o <= hi_i;
                lo_o <= lo_i;
    end
end

endmodule