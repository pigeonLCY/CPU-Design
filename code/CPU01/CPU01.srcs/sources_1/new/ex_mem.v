//ex_mem.v ִ��--�ô�
`include "defines.v"

module ex_mem (
    clk,     //ʱ��
    rst,     //��λ
    //ex�δ���������
    ex_wd,      //дʹ��
    ex_wreg,    //д�ĵ�ַ
    ex_wdata,   //д������
    ex_hi,      //ex��hi��ֵ
    ex_lo,      //ex��lo��ֵ
    ex_whilo,    //ex�δ�����hilo��дʹ��
    //����mem�ε�����
    mem_wd,      //д�ĵ�ַ
    mem_wreg,    //д�ĵ�ַ
    mem_wdata,   //д������
    mem_hi,      //����mem�ε�hi��ֵ
    mem_lo,      //����mem�ε�lo��ֵ
    mem_whilo    //дhilo��ʹ��
);
//----------------------------------------------
//�����ߺͼĴ����Ķ���
//��Ӧ��������
//----------------------------------------------
input wire					clk;
input wire					rst;
input wire[`RegAddrBus]      ex_wd; //ex�δ���������	
input wire                   ex_wreg;
input wire[`RegBus]	    ex_wdata;
input wire[`RegBus]     ex_hi;
input wire[`RegBus]     ex_lo;
input wire              ex_whilo; 	
output reg[`RegAddrBus]     mem_wd; //����mem�ε�����
output reg                  mem_wreg;
output reg[`RegBus]		    mem_wdata;
output reg[`RegBus]         mem_hi;
output reg[`RegBus]         mem_lo;
output reg                  mem_whilo;

//ʱ���·
//func������ex���źŵ�mem��
always @(posedge clk) begin //ʱ��������
    //�����λ���������ݻָ�ΪĬ��ֵ
    if(rst==`RstEnable) begin
        mem_wd <= `NOPRegAddr; //д��ַλΪ��
        mem_wreg <= `WriteDisable;//дʹ��Ϊ0����--����д
        mem_wdata <= `ZeroWord; //д��������0
        mem_hi <= `ZeroWord; //д��������0
        mem_lo <= `ZeroWord; //д��������0
        mem_whilo <= `ZeroWord; //д��������0
    end else begin
        //��ex�ε�����ȫ�����ݵ�mem��
        mem_wd <= ex_wd; 
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;	
        mem_hi <= ex_hi;
        mem_lo <= ex_lo;
        mem_whilo <= ex_whilo;	
    end   
end
endmodule



