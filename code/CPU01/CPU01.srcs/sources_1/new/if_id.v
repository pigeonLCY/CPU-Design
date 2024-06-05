//if_id 取指--译码
`include "defines.v"
module if_id(
    //定义名称
    clk, 	//时钟信号
    rst, 	//复位信号
    if_pc,  //if段来的pc
    if_inst,
    id_pc,  //传给id段的pc
    id_inst //传给id段的指令
);
//实现类型
input	wire    clk; //时钟信号
input wire      rst; //复位信号
input wire[`InstAddrBus]      if_pc;    //if段来的pc
input wire[`InstBus]          if_inst;  //if段来的指令
output reg[`InstAddrBus]      id_pc;    //传给id段的pc
output reg[`InstBus]          id_inst;  //传给id段的指令

//功能实现
//时序电路
always @(posedge clk)begin
    //先考虑是否复位
    if(rst == `RstEnable)begin //复位
        id_pc <= `ZeroWord; //0
        id_inst <= `ZeroWord; //0
    end else begin
        // 将if段的数据传递给id段
        id_pc <= if_pc; 
        id_inst <= if_inst;
    end
end


endmodule