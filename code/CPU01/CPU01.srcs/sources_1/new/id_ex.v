//id_ex ����--ִ��

`include "defines.v"

module id_ex(
    //���ƶ���
    clk,        //ʱ���ź�
    rst,        //��λ�ź�
	//����id������
    id_aluop,   //��������
    id_alusel,  //��������
    id_reg1,    //Դ������1
    id_reg2,    //Դ������2
    id_wd,      //д��ַ
    id_wreg,	//�Ƿ���д��Ŀ�ļĴ���
	//�͸�ex�ε�����
    ex_aluop,   //��������
    ex_alusel,  //��������
    ex_reg1,    //Դ������1
    ex_reg2,    //Դ������2
    ex_wd,      //д��ַ
    ex_wreg     //�Ƿ���д��Ŀ�ļĴ���
);
//����ʵ��
input wire  clk;
input wire  rst;
//����id������
input wire[`AluOpBus]   id_aluop;   //id����������
input wire[`AluSelBus]  id_alusel;  //id����������
input wire[`RegBus]     id_reg1;    //id��Դ������1
input wire[`RegBus]     id_reg2;    //id��Դ������2
input wire[`RegAddrBus] id_wd;      //id��д��ַ
input wire              id_wreg;    //id���Ƿ���д��Ŀ�ļĴ���
//�͸�ex�ε�����
output reg[`AluOpBus]   ex_aluop;   //ex����������
output reg[`AluSelBus]  ex_alusel;  //ex����������
output reg[`RegBus]     ex_reg1;    //ex��Դ������1
output reg[`RegBus]     ex_reg2;    //ex��Դ������2
output reg[`RegAddrBus] ex_wd;      //ex��д��ַ
output reg              ex_wreg;    //ex���Ƿ���д��Ŀ�ļĴ���

//ʱ���߼���·
//func:��id�ε��źŴ��ݵ�ex��
always @ (posedge clk) begin
    if (rst == `RstEnable) begin //��λ
        ex_aluop <= `EXE_NOP_OP;
        ex_alusel <= `EXE_RES_NOP;
        ex_reg1 <= `ZeroWord;
        ex_reg2 <= `ZeroWord;
        ex_wd <= `NOPRegAddr;
        ex_wreg <= `WriteDisable;
    end else begin		
        //��id�������ź����θ�ֵ��ex���źż���
        ex_aluop <= id_aluop;   
        ex_alusel <= id_alusel;
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_wd <= id_wd;
        ex_wreg <= id_wreg;		
    end
end
	
endmodule