//ex ִ��

`include "defines.v"

module ex(
	rst,        //��λ�ź�
    aluop_i,    //��������
    alusel_i,   //��������
    reg1_i,     //ex�ν��յ���Դ������1
    reg2_i,     //ex�ν��յ���Դ������2
    wd_i,       //ex�ν��յ���д��ַ
    wreg_i,     //ex�ν��յ���дʹ��
    hi_i,       //HI�Ĵ���
    lo_i,       //LO�Ĵ���
//-----------------------------------------------------
//���wb��mem�ζ���hilo�ķ��ʣ�����hilo���ڵ����
    wb_hi_i,    //wb��дhi��ֵ
    wb_lo_i,    //wb��дlo��ֵ
    wb_whilo_i, //wb���Ƿ�Ҫдhilo

    mem_hi_i,   //mem��дhi��ֵ
    mem_lo_i,   //mem��дlo��ֵ
    mem_whilo_i,//mem���Ƿ�Ҫдhilo
//-----------------------------------------------------
    wd_o,       //ex��"д��ַ"
    wreg_o,     //ex��"дʹ��"
    wdata_o,    //ex��"д����"
    hi_o,       //ex��дhi��ֵ
    lo_o,       //ex��дlo��ֵ
    whilo_o	    //ex���Ƿ�Ҫдhilo
);
//========================================================
//���Ͷ���
input wire  rst;//��λ�ź�
input wire[`AluOpBus]   aluop_i;    //��������
input wire[`AluSelBus]  alusel_i;   //��������
input wire[`RegBus]     reg1_i;     //ex�ν��յ���Դ������1
input wire[`RegBus]     reg2_i;     //ex�ν��յ���Դ������2
input wire[`RegAddrBus] wd_i;       //ex�ν��յ���д��ַ
input wire              wreg_i;     //ex�ν��յ���дʹ��
input wire[`RegBus]     hi_i;       //HI�Ĵ���
input wire[`RegBus]     lo_i;       //LO�Ĵ���

input wire[`RegBus]     wb_hi_i;    //wb��дhi��ֵ
input wire[`RegBus]     wb_lo_i;    //wb��дlo��ֵ
input wire              wb_whilo_i; //wb���Ƿ�Ҫдhilo
input wire[`RegBus]     mem_hi_i;   //mem��дhi��ֵ
input wire[`RegBus]     mem_lo_i;   //mem��дlo��ֵ
input wire              mem_whilo_i;//mem���Ƿ�Ҫдhilo

output reg[`RegAddrBus] wd_o;   //ex��"д��ַ"
output reg              wreg_o; //ex��"дʹ��"
output reg[`RegBus]	    wdata_o;//ex��"д����"
output reg[`RegBus]     hi_o;   //ex��дhi��ֵ
output reg[`RegBus]     lo_o;   //ex��дlo��ֵ
output reg              whilo_o;	//ex���Ƿ�Ҫдhilo
//========================================================

reg[`RegBus] logicout;      //�߼�������
reg[`RegBus] shiftres;      //��λ������
reg[`RegBus] moveres;       //�ƶ��������
reg[`RegBus] arithmeticres; //����������
reg[`DoubleRegBus] mulres;	//�˷�������
reg[`RegBus] divres1; //������
reg[`RegBus] divres2; //��������
reg[`RegBus] HI;    //hi
reg[`RegBus] LO;    //lo
wire[`RegBus] reg2_i_mux;   //Դ������2�Ĳ���
wire[`RegBus] reg1_i_not;   //Դ������2�ķ���
wire[`RegBus] result_sum;   //"��"���
wire ov_sum;                //����������
wire reg1_eq_reg2;  //r1 �Ƿ�= r2
wire reg1_lt_reg2;  //r1 �Ƿ�< r2
wire[`RegBus] opdata1_mult;     //������
wire[`RegBus] opdata2_mult;     //����
wire[`DoubleRegBus] hilo_temp;	//�˷������ʱ����


wire[`RegBus] opdata1_div;     //������
wire[`RegBus] opdata2_div;     //����
wire[`RegBus] opdata3_div;     //����
wire[`RegBus] opdata4_div;     //��



//����߼���·
//func���߼�����
always @ (*) begin
    if(rst == `RstEnable) begin //��λ
        logicout <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_OR_OP:			begin
                logicout <= reg1_i | reg2_i;    //or
                end
            `EXE_AND_OP:		begin
                logicout <= reg1_i & reg2_i;    //and
                end
            `EXE_NOR_OP:		begin
                logicout <= ~(reg1_i |reg2_i);  //nor
                end
            `EXE_XOR_OP:		begin
                logicout <= reg1_i ^ reg2_i;    //xor
                end
            default:				begin
                logicout <= `ZeroWord;          //����
                end
        endcase
    end    
end     



//����߼���·
//func����λ����
always @ (*) begin
    if(rst == `RstEnable) begin //��λ
        shiftres <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_SLL_OP:	    begin //shfit left logic
                shiftres <= reg2_i << reg1_i[4:0] ;
                end
            `EXE_SRL_OP:		begin //shfit right logic
                shiftres <= reg2_i >> reg1_i[4:0];
                end
            `EXE_SRA_OP:		begin //shfit right arthimatic
                shiftres <= ({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
                            //���λ�Ƿ���λ�������λ�ķ��������ƶ� ��32-reg1_i[4:0]��λ����λ������0
                            //ԭ���������ƣ�reg1_i[4:0]��λ����λ��0
                            //���������㣬��λ�����λ��ͬ����λ���������ƵĽ����ͬ
                            //�Ӷ�ʵ����������
                end
            default:			begin //����
                shiftres <= `ZeroWord;
                end
        endcase
    end    
end      




//����Դ������2�Ĳ���
//�����������ʱ����Ҫ���㲹�룬
assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) || (aluop_i == `EXE_SLT_OP) )  ? (~reg2_i)+1 : reg2_i;

//����"�Ӻ�"�Ľ��,��������Ǽ�������Ľ���Ǽ�������������Ǽӷ����
assign result_sum = reg1_i + reg2_i_mux;										 

//�鿴�Ƿ����
//��������������+��=������+��=��
assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) || ((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));  

//r1�Ƿ�<r2
assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP)) ? //�з�������㣬�޷�����ֱ�ӱȽ�
                                                ((reg1_i[31] && !reg2_i[31]) || //r1<0 r2>0 ,�����1
                                                (!reg1_i[31] && !reg2_i[31] && result_sum[31])|| //r1��r2ͬ�ţ�������<0����Ϊ1
                            (reg1_i[31] && reg2_i[31] && result_sum[31]))
                            :	(reg1_i < reg2_i);

//ȡ��
assign reg1_i_not = ~reg1_i;




//����߼���·
//func:��������			
always @ (*) begin
    if(rst == `RstEnable) begin //��λ
        arithmeticres <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_SLT_OP, `EXE_SLTU_OP:		begin //r1 < r2
                arithmeticres <= reg1_lt_reg2 ;
                end
            `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP:		begin //�ӷ����
                arithmeticres <= result_sum; 
                end
            `EXE_SUB_OP, `EXE_SUBU_OP:		begin   //�������
                arithmeticres <= result_sum; 
                end		
            `EXE_CLZ_OP:		begin //��λ����zero�ĸ���
                //�ǳ�ʵ�õ���Ŀ���㣬�����if���Ļ���Ҫʹ�ô����Ƚ�����������Ĵ�
                arithmeticres <= reg1_i[31]     ? 0 :   reg1_i[30]  ? 1 : 
                                                        reg1_i[29]  ? 2 :
                                                        reg1_i[28]  ? 3 : 
                                                        reg1_i[27]  ? 4 : 
                                                        reg1_i[26]  ? 5 :
                                                        reg1_i[25]  ? 6 : 
                                                        reg1_i[24]  ? 7 : 
                                                        reg1_i[23]  ? 8 : 
                                                        reg1_i[22]  ? 9 : 
                                                        reg1_i[21]  ? 10 : 
                                                        reg1_i[20]  ? 11 :
                                                        reg1_i[19]  ? 12 : 
                                                        reg1_i[18]  ? 13 : 
                                                        reg1_i[17]  ? 14 : 
                                                        reg1_i[16]  ? 15 : 
                                                        reg1_i[15]  ? 16 : 
                                                        reg1_i[14]  ? 17 : 
                                                        reg1_i[13]  ? 18 : 
                                                        reg1_i[12]  ? 19 : 
                                                        reg1_i[11]  ? 20 :
                                                        reg1_i[10]  ? 21 : 
                                                        reg1_i[9]   ? 22 : 
                                                        reg1_i[8]   ? 23 : 
                                                        reg1_i[7]   ? 24 : 
                                                        reg1_i[6]   ? 25 : 
                                                        reg1_i[5]   ? 26 : 
                                                        reg1_i[4]   ? 27 : 
                                                        reg1_i[3]   ? 28 : 
                                                        reg1_i[2]   ? 29 : 
                                                        reg1_i[1]   ? 30 : 
                                                        reg1_i[0]   ? 31 : 32 ;
                end
            `EXE_CLO_OP:		begin //��λ����one�ĸ���
                arithmeticres <= (reg1_i_not[31] ? 0 :  reg1_i_not[30]  ? 1 : 
                                                        reg1_i_not[29]  ? 2 :
                                                        reg1_i_not[28]  ? 3 : 
                                                        reg1_i_not[27]  ? 4 : 
                                                        reg1_i_not[26]  ? 5 :
                                                        reg1_i_not[25]  ? 6 : 
                                                        reg1_i_not[24]  ? 7 : 
                                                        reg1_i_not[23]  ? 8 : 
                                                        reg1_i_not[22]  ? 9 : 
                                                        reg1_i_not[21]  ? 10 : 
                                                        reg1_i_not[20]  ? 11 :
                                                        reg1_i_not[19]  ? 12 : 
                                                        reg1_i_not[18]  ? 13 : 
                                                        reg1_i_not[17]  ? 14 : 
                                                        reg1_i_not[16]  ? 15 : 
                                                        reg1_i_not[15]  ? 16 : 
                                                        reg1_i_not[14]  ? 17 : 
                                                        reg1_i_not[13]  ? 18 : 
                                                        reg1_i_not[12]  ? 19 : 
                                                        reg1_i_not[11]  ? 20 :
                                                        reg1_i_not[10]  ? 21 : 
                                                        reg1_i_not[9]   ? 22 : 
                                                        reg1_i_not[8]   ? 23 : 
                                                        reg1_i_not[7]   ? 24 : 
                                                        reg1_i_not[6]   ? 25 : 
                                                        reg1_i_not[5]   ? 26 : 
                                                        reg1_i_not[4]   ? 27 : 
                                                        reg1_i_not[3]   ? 28 : 
                                                        reg1_i_not[2]   ? 29 : 
                                                        reg1_i_not[1]   ? 30 : 
                                                        reg1_i_not[0]   ? 31 : 32) ;
                end
            default:				begin
                arithmeticres <= `ZeroWord;
                end
        endcase
    end
end

//ȡ�ó˷������Ĳ�����
//�з��ų˷�
//�������Դ��
assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)) && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;
assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP))  && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;		

assign hilo_temp = opdata1_mult * opdata2_mult;		

//����߼���·
//func���˷�����
always @ (*) begin
    if(rst == `RstEnable) begin //��λ
        mulres <= {`ZeroWord,`ZeroWord};
    //�з��ų˷�
    end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP))begin
        if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin //�����������������
            mulres <= ~hilo_temp + 1;
        end else begin
            mulres <= hilo_temp;    //ͬ��
        end
    //�޷��ų˷�
    end else begin
            mulres <= hilo_temp;    
    end
end


// ȡ�ó��������Ĳ�����
// �з��ų���
// �������Դ��
assign opdata1_div = (((aluop_i == `EXE_DIV_OP) ) && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;
assign opdata2_div = (((aluop_i == `EXE_DIV_OP) )  && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;		

assign opdata3_div = opdata1_div / opdata2_div;
assign opdata4_div = opdata1_div % opdata2_div;
// ִ�г�������
// ʹ������߼���·ʵ�ֳ�������
always @ (*) begin
    if(rst == `RstEnable) begin //��λ
        divres1 <= `ZeroWord;
        divres2 <= `ZeroWord;
    //�з��ų˷�
    end else if ((aluop_i == `EXE_DIV_OP) )begin
        if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin //�����������������
            divres1 <= ~opdata3_div+1;
            divres2 <= ~opdata4_div+1;
        end else begin
            divres1 <= opdata3_div;
            divres2 <= opdata4_div;    //ͬ��
        end
    //�޷��ų˷�
    end else begin
            divres1 <= opdata3_div;
            divres2 <= opdata4_div;
    end
end

//����߼���·
//func������hi,lo,���ָ�������������
always @ (*) begin
    if(rst == `RstEnable) begin //��λ
        {HI,LO} <= {`ZeroWord,`ZeroWord};
    end else if(mem_whilo_i == `WriteEnable) begin //mem��Ҫдhilo����mem��Ҫд������д�뵽hilo��
        {HI,LO} <= {mem_hi_i,mem_lo_i};
    end else if(wb_whilo_i == `WriteEnable) begin //wbҪдhilo����mem��Ҫд������д�뵽hilo��
        {HI,LO} <= {wb_hi_i,wb_lo_i};
    end else begin  //��û��д�����ҿ���ֱ�Ӹ��¼��������
        {HI,LO} <= {hi_i,lo_i};			
    end
end	


//����߼���·
//func���ƶ�����
//����MFHI��MFLO��MOVN��MOVZָ��
always @ (*) begin
    if(rst == `RstEnable) begin //��λ
        moveres <= `ZeroWord;
    end else begin
        moveres <= `ZeroWord;
    case (aluop_i)
        `EXE_MFHI_OP:		begin   //move from hi
            moveres <= HI;
            end
        `EXE_MFLO_OP:		begin
            moveres <= LO;          //move from lo
            end
        `EXE_MOVZ_OP:		begin
            moveres <= reg1_i;      //move if zero
            end
        `EXE_MOVN_OP:		begin
            moveres <= reg1_i;      //move if not zero
            end
        default : begin
            end
    endcase
    end
end	 


//����߼���·
//func����������������ѡ����
always @ (*) begin
    wd_o <= wd_i;   
    //�Ӽ��������"��д"
    if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) ||  (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
        wreg_o <= `WriteDisable;
    end else begin
        wreg_o <= wreg_i;
    end

    case ( alusel_i ) 
        `EXE_RES_LOGIC:		begin       //�߼�������
            wdata_o <= logicout;
            end
        `EXE_RES_SHIFT:		begin       //��λ������
            wdata_o <= shiftres;
            end	 	
        `EXE_RES_MOVE:		begin       //�ƶ��������
            wdata_o <= moveres;
            end	 	
        `EXE_RES_ARITHMETIC:    begin   //����������
            wdata_o <= arithmeticres;
            end
        `EXE_RES_MUL:   begin           //�˷�������
            wdata_o <= mulres[31:0];
            end	 	
        default:        begin
            wdata_o <= `ZeroWord;
            end
    endcase
end	


//����߼���·
//func��ȷ����hilo�Ĳ�����Ϣ
always @ (*) begin
    if(rst == `RstEnable) begin //��λ
        whilo_o <= `WriteDisable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;		
    end else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin //�˷�
        whilo_o <= `WriteEnable;
        hi_o <= mulres[63:32];  //��32λ����hi
        lo_o <= mulres[31:0];   //��32λ����lo
    end else if((aluop_i == `EXE_DIV_OP) || (aluop_i == `EXE_DIVU_OP)) begin //�˷�
        whilo_o <= `WriteEnable;
        hi_o <= divres1;  //��32λ����hi
        lo_o <= divres2;   //��32λ����lo
    end else if(aluop_i == `EXE_MTHI_OP) begin //��hi���ƶ�����
        whilo_o <= `WriteEnable;
        hi_o <= reg1_i;
        lo_o <= LO;
    end else if(aluop_i == `EXE_MTLO_OP) begin  //��lo���ƶ�����
        whilo_o <= `WriteEnable;
        hi_o <= HI;
        lo_o <= reg1_i;
    end else begin
        whilo_o <= `WriteDisable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
    end				
end			

endmodule