//id_ex 译码--执行

`include "defines.v"

module id_ex(
    //名称定义
    clk,        //时钟信号
    rst,        //复位信号
	//来自id段数据
    id_aluop,   //运算子类
    id_alusel,  //运算主类
    id_reg1,    //源操作数1
    id_reg2,    //源操作数2
    id_wd,      //写地址
    id_wreg,	//是否有写的目的寄存器
	//送给ex段的数据
    ex_aluop,   //运算子类
    ex_alusel,  //运算主类
    ex_reg1,    //源操作数1
    ex_reg2,    //源操作数2
    ex_wd,      //写地址
    ex_wreg     //是否有写的目的寄存器
);
//类型实现
input wire  clk;
input wire  rst;
//来自id段数据
input wire[`AluOpBus]   id_aluop;   //id段运算子类
input wire[`AluSelBus]  id_alusel;  //id段运算主类
input wire[`RegBus]     id_reg1;    //id段源操作数1
input wire[`RegBus]     id_reg2;    //id段源操作数2
input wire[`RegAddrBus] id_wd;      //id段写地址
input wire              id_wreg;    //id段是否有写的目的寄存器
//送给ex段的数据
output reg[`AluOpBus]   ex_aluop;   //ex段运算子类
output reg[`AluSelBus]  ex_alusel;  //ex段运算主类
output reg[`RegBus]     ex_reg1;    //ex段源操作数1
output reg[`RegBus]     ex_reg2;    //ex段源操作数2
output reg[`RegAddrBus] ex_wd;      //ex段写地址
output reg              ex_wreg;    //ex段是否有写的目的寄存器

//时序逻辑电路
//func:将id段的信号传递到ex段
always @ (posedge clk) begin
    if (rst == `RstEnable) begin //复位
        ex_aluop <= `EXE_NOP_OP;
        ex_alusel <= `EXE_RES_NOP;
        ex_reg1 <= `ZeroWord;
        ex_reg2 <= `ZeroWord;
        ex_wd <= `NOPRegAddr;
        ex_wreg <= `WriteDisable;
    end else begin		
        //将id段所有信号依次赋值给ex段信号即可
        ex_aluop <= id_aluop;   
        ex_alusel <= id_alusel;
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_wd <= id_wd;
        ex_wreg <= id_wreg;		
    end
end
	
endmodule