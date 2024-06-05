//inst_rom ָ��洢��

`include "defines.v"

module inst_rom(

    ce,     //ָ��洢��ʹ��
    addr,   //ָ���ַ
    inst    //ȡ�õ�ָ��
	
);


input wire      ce; //ָ��洢��ʹ��
input wire[`InstAddrBus]    addr;   //ָ���ַ
output reg[`InstBus]	    inst;   //ȡ�õ�ָ��

reg[`InstBus]  inst_mem[0:`InstMemNum-1]; //ָ��32λ

initial $readmemh ( "F:\inst_rom.data", inst_mem ); //ָ�����ڵ��ļ�

//func�����ݵ�ַȡ��ָ��
always @ (*) begin  
    if (ce == `ChipDisable) begin
        inst <= `ZeroWord;
    end else begin
        inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
    end
end

endmodule