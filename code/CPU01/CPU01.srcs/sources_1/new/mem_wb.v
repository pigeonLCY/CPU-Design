//mem_wb �ô�--��д
`include "defines.v"

module mem_wb(

    clk,        //ʱ���ź�
    rst,        //��λ�ź�
    mem_wd,     //memд��ַ
    mem_wreg,   //memдʹ��
    mem_wdata,  //memд����
    mem_hi,     //mem��hi
    mem_lo,     //mem��lo
    mem_whilo,  //mem��дhiloʹ��
    wb_wd,      //wbд��ַ
    wb_wreg,    //wbдʹ��
    wb_wdata,   //wbд����
    wb_hi,      //wb��hi
    wb_lo,      //wb��lo
    wb_whilo   //wb��дhiloʹ��	       
);

input wire clk; //ʱ���ź�
input wire rst; //��λ�ź�
input wire[`RegAddrBus] mem_wd;     //memд��ַ
input wire              mem_wreg;   //memдʹ��
input wire[`RegBus]	    mem_wdata;  //memд����
input wire[`RegBus]     mem_hi;     //mem��hi
input wire[`RegBus]     mem_lo;     //mem��lo
input wire              mem_whilo;	//mem��дhiloʹ��

//�͵���д�׶ε���Ϣ
output reg[`RegAddrBus] wb_wd;      //wbд��ַ
output reg              wb_wreg;    //wbдʹ��
output reg[`RegBus]		wb_wdata;   //wbд����
output reg[`RegBus]     wb_hi;      //wb��hi
output reg[`RegBus]     wb_lo;      //wb��lo
output reg              wb_whilo;   //wb��дhiloʹ��

//ʱ���߼���·
//func
always @ (posedge clk) begin
    if(rst == `RstEnable) begin //��λ
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteDisable;
        wb_wdata <= `ZeroWord;	
        wb_hi <= `ZeroWord;
        wb_lo <= `ZeroWord;
        wb_whilo <= `WriteDisable;		  
    end else begin
        //��mem�ε����ݴ��͵�wb��
        wb_wd <= mem_wd;
        wb_wreg <= mem_wreg;
        wb_wdata <= mem_wdata;
        wb_hi <= mem_hi;
        wb_lo <= mem_lo;
        wb_whilo <= mem_whilo;			
    end 
end    
			

endmodule