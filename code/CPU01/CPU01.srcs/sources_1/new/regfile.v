//���е�ͨ�üĴ���
`include "defines.v"
module regfile( 
    //��������
    clk,    //ʱ���ź�
    rst,    //��λ�ź�
    we,     //дʹ�� 
    waddr,  //д��ַ
    wdata,  //д����
    re1,    //��ʹ��1
    raddr1, //����ַ1
    rdata1, //������1
    re2,    //��ʹ��2
    raddr2, //����ַ2
    rdata2,  //������2
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
//ʵ������
//RegAddrBus-32
//RegBus-32
input wire	clk;
input wire  rst;
//д
input wire		we;
input wire[`RegAddrBus] waddr;  //���ΪRegAddrBus 4:0
input wire[`RegBus]	    wdata;  //���ΪRegBus 31:0
//��1
input wire		re1;
input wire[`RegAddrBus]	raddr1; //���ΪRegAddrBus
output reg[`RegBus]     rdata1; //���ΪRegBus
//��2
input wire		re2;
input wire[`RegAddrBus]	raddr2; //���ΪRegAddrBus
output reg[`RegBus]     rdata2; //���ΪRegBus
//����led��������
output wire 	led0_o;   //led0
output wire    led1_o;   //led1
output wire    led2_o;   //led2
output wire    led3_o;   //led3
output wire 	led4_o;   //led0
output wire    led5_o;   //led1
output wire    led6_o;   //led2
output wire    led7_o;   //led3
//�ؼ�������32��32λ�Ĵ���
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
//ʱ���·
//func:��ָ���Ĵ���д������
always @(posedge clk) begin
    if(rst == `RstDisable) begin //����λ
    //д���� �� д�Ĳ���0�Ĵ�����0�Ĵ�����Ϊ�㣬��������ģ�
        if((we ==   `WriteEnable) && (waddr != `RegNumLog2'h0)) begin 
            regs[waddr] <= wdata;   
        end
        
    end
end

//����߼���·
//func:���˿�1ָ���ļĴ���
always @(*) begin
    //�κ�ʱ�������ж��Ƿ�"��λ"����
    if(rst == `RstEnable) begin //��λ
        rdata1 <= `ZeroWord;
    end else if(raddr1 == `RegNumLog2'h0) begin //��$0�Ĵ�������0
        rdata1 <= `ZeroWord;
    //����ǰ�ƣ�"���ĵ�ַ"��"д�ĵ�ַ"�պ���ͬ�����Ҵ�ʱcpu��Ҫ"��"ҲҪ"д"����ֱ�ӵõ�����
    end else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin
        rdata1 <= wdata;
    //�޷�ǰ����ӼĴ�����ȡ����
    end else if(re1 == `ReadEnable) begin
        rdata1 <= regs[raddr1];
    //���������ֵΪ0
    end else begin 
        rdata1 <= `ZeroWord;
    end
end

//����߼���·
//func:���˿�2ָ���ļĴ���
always @ (*) begin
    if(rst == `RstEnable) begin //��λ
            rdata2 <= `ZeroWord;
    end else if(raddr2 == `RegNumLog2'h0) begin //��$0�Ĵ�������0
        rdata2 <= `ZeroWord;
    //����ǰ�ƣ�"���ĵ�ַ"��"д�ĵ�ַ"�պ���ͬ�����Ҵ�ʱcpu��Ҫ"��"ҲҪ"д"����ֱ�ӵõ�����
    end else if((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin
        rdata2 <= wdata;
    //�޷�ǰ����ӼĴ�����ȡ����
    end else if(re2 == `ReadEnable) begin
        rdata2 <= regs[raddr2];
    //���������ֵΪ0
    end else begin
        rdata2 <= `ZeroWord;
    end
end


endmodule