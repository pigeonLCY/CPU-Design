//if_id ȡָ--����
`include "defines.v"
module if_id(
    //��������
    clk, 	//ʱ���ź�
    rst, 	//��λ�ź�
    if_pc,  //if������pc
    if_inst,
    id_pc,  //����id�ε�pc
    id_inst //����id�ε�ָ��
);
//ʵ������
input	wire    clk; //ʱ���ź�
input wire      rst; //��λ�ź�
input wire[`InstAddrBus]      if_pc;    //if������pc
input wire[`InstBus]          if_inst;  //if������ָ��
output reg[`InstAddrBus]      id_pc;    //����id�ε�pc
output reg[`InstBus]          id_inst;  //����id�ε�ָ��

//����ʵ��
//ʱ���·
always @(posedge clk)begin
    //�ȿ����Ƿ�λ
    if(rst == `RstEnable)begin //��λ
        id_pc <= `ZeroWord; //0
        id_inst <= `ZeroWord; //0
    end else begin
        // ��if�ε����ݴ��ݸ�id��
        id_pc <= if_pc; 
        id_inst <= if_inst;
    end
end


endmodule