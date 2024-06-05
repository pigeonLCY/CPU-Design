//mem 访存

`include "defines.v"

module mem(
	//定义名称
    rst, //复位信号
    //输入：ex段的数据
    wd_i,   //写地址
    wreg_i, //写使能
    wdata_i,//写数据
    hi_i,   //hi数据
    lo_i,   //lo数据
    whilo_i,//hilo写使能
    //输出：wb段的数据
    wd_o,   //写地址
    wreg_o, //写使能
    wdata_o,//写数据
    hi_o,   //hi数据
    lo_o,   //lo数据
    whilo_o //hilo写使能
);
//定义类型
input wire  rst;
//来自执行阶段的信息	
input wire[`RegAddrBus] wd_i;
input wire              wreg_i;
input wire[`RegBus]	    wdata_i;
input wire[`RegBus]     hi_i;
input wire[`RegBus]     lo_i;
input wire              whilo_i;	
//送到回写阶段的信息
output reg[`RegAddrBus] wd_o;
output reg              wreg_o;
output reg[`RegBus]	    wdata_o;
output reg[`RegBus]     hi_o;
output reg[`RegBus]     lo_o;
output reg              whilo_o;

//组合逻辑电路
//func：传出mem段的信号
always @ (*) begin
    if(rst == `RstEnable) begin //复位
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        wdata_o <= `ZeroWord;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
        whilo_o <= `WriteDisable;		  
    end else begin  //将信号全部传递到wb段
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
        hi_o <= hi_i;
        lo_o <= lo_i;
        whilo_o <= whilo_i;			
    end   
end      
			

endmodule