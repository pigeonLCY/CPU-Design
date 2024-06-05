//所有的通用寄存器
`include "defines.v"
module regfile( 
    //定义名称
    clk,    //时钟信号
    rst,    //复位信号
    we,     //写使能 
    waddr,  //写地址
    wdata,  //写数据
    re1,    //读使能1
    raddr1, //读地址1
    rdata1, //读数据1
    re2,    //读使能2
    raddr2, //读地址2
    rdata2,  //读数据2
    //led
    led0_o,  //led0
	led1_o,  //led1
	led2_o,  //led2
	led3_o,   //led3
	led4_o,  //led0
    led5_o,  //led1
    led6_o,  //led2
    led7_o   //led3
);
//实现类型
//RegAddrBus-32
//RegBus-32
input wire	clk;
input wire  rst;
//写
input wire		we;
input wire[`RegAddrBus] waddr;  //宽度为RegAddrBus 4:0
input wire[`RegBus]	    wdata;  //宽度为RegBus 31:0
//读1
input wire		re1;
input wire[`RegAddrBus]	raddr1; //宽度为RegAddrBus
output reg[`RegBus]     rdata1; //宽度为RegBus
//读2
input wire		re2;
input wire[`RegAddrBus]	raddr2; //宽度为RegAddrBus
output reg[`RegBus]     rdata2; //宽度为RegBus
//连接led的四条线
output wire 	led0_o;   //led0
output wire    led1_o;   //led1
output wire    led2_o;   //led2
output wire    led3_o;   //led3
output wire 	led4_o;   //led0
output wire    led5_o;   //led1
output wire    led6_o;   //led2
output wire    led7_o;   //led3
//关键：定义32个32位寄存器
//RegNum-32
reg[`RegBus]  regs[0:`RegNum-1];
assign led0_o = regs[32'h00000003][32'h00000000]; //led0
assign led1_o = regs[32'h00000003][32'h00000001]; //led1
assign led2_o = regs[32'h00000003][32'h00000002]; //led2
assign led3_o = regs[32'h00000003][32'h00000003]; //led3
assign led4_o = regs[32'h00000003][32'h00000004]; //led4
assign led5_o = regs[32'h00000003][32'h00000005]; //led5
assign led6_o = regs[32'h00000003][32'h00000006]; //led6
assign led7_o = regs[32'h00000003][32'h00000007]; //led7
//时序电路
//func:给指定寄存器写入数据
always @(posedge clk) begin
    if(rst == `RstDisable) begin //不复位
    //写数据 且 写的不是0寄存器（0寄存器恒为零，不允许更改）
        if((we ==   `WriteEnable) && (waddr != `RegNumLog2'h0)) begin 
            regs[waddr] <= wdata;   
        end
        
    end
end

//组合逻辑电路
//func:读端口1指定的寄存器
always @(*) begin
    //任何时候首先判断是否"复位"！！
    if(rst == `RstEnable) begin //复位
        rdata1 <= `ZeroWord;
    end else if(raddr1 == `RegNumLog2'h0) begin //读$0寄存器，给0
        rdata1 <= `ZeroWord;
    //数据前推："读的地址"和"写的地址"刚好相同，并且此时cpu既要"读"也要"写"，则直接得到数据
    end else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin
        rdata1 <= wdata;
    //无法前推则从寄存器中取数据
    end else if(re1 == `ReadEnable) begin
        rdata1 <= regs[raddr1];
    //其他情况赋值为0
    end else begin 
        rdata1 <= `ZeroWord;
    end
end

//组合逻辑电路
//func:读端口2指定的寄存器
always @ (*) begin
    if(rst == `RstEnable) begin //复位
            rdata2 <= `ZeroWord;
    end else if(raddr2 == `RegNumLog2'h0) begin //读$0寄存器，给0
        rdata2 <= `ZeroWord;
    //数据前推："读的地址"和"写的地址"刚好相同，并且此时cpu既要"读"也要"写"，则直接得到数据
    end else if((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin
        rdata2 <= wdata;
    //无法前推则从寄存器中取数据
    end else if(re2 == `ReadEnable) begin
        rdata2 <= regs[raddr2];
    //其他情况赋值为0
    end else begin
        rdata2 <= `ZeroWord;
    end
end


endmodule