//ex_mem.v 执行--访存
`include "defines.v"

module ex_mem (
    clk,     //时钟
    rst,     //复位
    //ex段传来的数据
    ex_wd,      //写使能
    ex_wreg,    //写的地址
    ex_wdata,   //写的数据
    ex_hi,      //ex段hi的值
    ex_lo,      //ex段lo的值
    ex_whilo,    //ex段传来的hilo的写使能
    //传向mem段的数据
    mem_wd,      //写的地址
    mem_wreg,    //写的地址
    mem_wdata,   //写的数据
    mem_hi,      //传向mem段的hi的值
    mem_lo,      //传向mem段的lo的值
    mem_whilo    //写hilo的使能
);
//----------------------------------------------
//各种线和寄存器的定义
//对应含义如上
//----------------------------------------------
input wire					clk;
input wire					rst;
input wire[`RegAddrBus]      ex_wd; //ex段传来的数据	
input wire                   ex_wreg;
input wire[`RegBus]	    ex_wdata;
input wire[`RegBus]     ex_hi;
input wire[`RegBus]     ex_lo;
input wire              ex_whilo; 	
output reg[`RegAddrBus]     mem_wd; //传向mem段的数据
output reg                  mem_wreg;
output reg[`RegBus]		    mem_wdata;
output reg[`RegBus]         mem_hi;
output reg[`RegBus]         mem_lo;
output reg                  mem_whilo;

//时序电路
//func：传送ex的信号到mem段
always @(posedge clk) begin //时钟上升沿
    //如果复位则将所有数据恢复为默认值
    if(rst==`RstEnable) begin
        mem_wd <= `NOPRegAddr; //写地址位为空
        mem_wreg <= `WriteDisable;//写使能为0，即--不许写
        mem_wdata <= `ZeroWord; //写的数据是0
        mem_hi <= `ZeroWord; //写的数据是0
        mem_lo <= `ZeroWord; //写的数据是0
        mem_whilo <= `ZeroWord; //写的数据是0
    end else begin
        //将ex段的数据全部传递到mem段
        mem_wd <= ex_wd; 
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;	
        mem_hi <= ex_hi;
        mem_lo <= ex_lo;
        mem_whilo <= ex_whilo;	
    end   
end
endmodule



