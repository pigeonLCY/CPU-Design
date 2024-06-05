//inst_rom 指令存储器

`include "defines.v"

module inst_rom(

    ce,     //指令存储器使能
    addr,   //指令地址
    inst    //取得的指令
	
);


input wire      ce; //指令存储器使能
input wire[`InstAddrBus]    addr;   //指令地址
output reg[`InstBus]	    inst;   //取得的指令

reg[`InstBus]  inst_mem[0:`InstMemNum-1]; //指令32位

initial $readmemh ( "F:\inst_rom.data", inst_mem ); //指令所在的文件

//func：根据地址取出指令
always @ (*) begin  
    if (ce == `ChipDisable) begin
        inst <= `ZeroWord;
    end else begin
        inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
    end
end

endmodule