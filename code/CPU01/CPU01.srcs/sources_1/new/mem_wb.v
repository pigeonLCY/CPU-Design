//mem_wb 访存--回写
`include "defines.v"

module mem_wb(

    clk,        //时钟信号
    rst,        //复位信号
    mem_wd,     //mem写地址
    mem_wreg,   //mem写使能
    mem_wdata,  //mem写数据
    mem_hi,     //mem段hi
    mem_lo,     //mem段lo
    mem_whilo,  //mem段写hilo使能
    wb_wd,      //wb写地址
    wb_wreg,    //wb写使能
    wb_wdata,   //wb写数据
    wb_hi,      //wb段hi
    wb_lo,      //wb段lo
    wb_whilo   //wb段写hilo使能	       
);

input wire clk; //时钟信号
input wire rst; //复位信号
input wire[`RegAddrBus] mem_wd;     //mem写地址
input wire              mem_wreg;   //mem写使能
input wire[`RegBus]	    mem_wdata;  //mem写数据
input wire[`RegBus]     mem_hi;     //mem段hi
input wire[`RegBus]     mem_lo;     //mem段lo
input wire              mem_whilo;	//mem段写hilo使能

//送到回写阶段的信息
output reg[`RegAddrBus] wb_wd;      //wb写地址
output reg              wb_wreg;    //wb写使能
output reg[`RegBus]		wb_wdata;   //wb写数据
output reg[`RegBus]     wb_hi;      //wb段hi
output reg[`RegBus]     wb_lo;      //wb段lo
output reg              wb_whilo;   //wb段写hilo使能

//时序逻辑电路
//func
always @ (posedge clk) begin
    if(rst == `RstEnable) begin //复位
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteDisable;
        wb_wdata <= `ZeroWord;	
        wb_hi <= `ZeroWord;
        wb_lo <= `ZeroWord;
        wb_whilo <= `WriteDisable;		  
    end else begin
        //将mem段的数据传送到wb段
        wb_wd <= mem_wd;
        wb_wreg <= mem_wreg;
        wb_wdata <= mem_wdata;
        wb_hi <= mem_hi;
        wb_lo <= mem_lo;
        wb_whilo <= mem_whilo;			
    end 
end    
			

endmodule