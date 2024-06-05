//mem �ô�

`include "defines.v"

module mem(
	//��������
    rst, //��λ�ź�
    //���룺ex�ε�����
    wd_i,   //д��ַ
    wreg_i, //дʹ��
    wdata_i,//д����
    hi_i,   //hi����
    lo_i,   //lo����
    whilo_i,//hiloдʹ��
    //�����wb�ε�����
    wd_o,   //д��ַ
    wreg_o, //дʹ��
    wdata_o,//д����
    hi_o,   //hi����
    lo_o,   //lo����
    whilo_o //hiloдʹ��
);
//��������
input wire  rst;
//����ִ�н׶ε���Ϣ	
input wire[`RegAddrBus] wd_i;
input wire              wreg_i;
input wire[`RegBus]	    wdata_i;
input wire[`RegBus]     hi_i;
input wire[`RegBus]     lo_i;
input wire              whilo_i;	
//�͵���д�׶ε���Ϣ
output reg[`RegAddrBus] wd_o;
output reg              wreg_o;
output reg[`RegBus]	    wdata_o;
output reg[`RegBus]     hi_o;
output reg[`RegBus]     lo_o;
output reg              whilo_o;

//����߼���·
//func������mem�ε��ź�
always @ (*) begin
    if(rst == `RstEnable) begin //��λ
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        wdata_o <= `ZeroWord;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
        whilo_o <= `WriteDisable;		  
    end else begin  //���ź�ȫ�����ݵ�wb��
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
        hi_o <= hi_i;
        lo_o <= lo_i;
        whilo_o <= whilo_i;			
    end   
end      
			

endmodule