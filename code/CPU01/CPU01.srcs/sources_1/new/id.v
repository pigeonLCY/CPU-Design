//id ����
`include "defines.v"

module id(
//���ƶ���
    rst,    //��λ�ź�
    //xx_i�����뵽id�ε�����
    //xx_o����id�����������
    pc_i,   //pc
    inst_i, //ȡ�õ�ָ��
//---------------------------------------------------------------------
//����ǰ�ƣ���ȡex�κ�mem��"д"�������Ȼ������Ҫ����ʱ�����ֱ�ӻ�ȡ����
    //����ִ�н׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
    ex_wreg_i,  //ex���Ƿ�Ҫ"д"
    ex_wdata_i, //ex��д"����"
    ex_wd_i,    //ex��д"��ַ"
    //���ڷô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
    mem_wreg_i, //mem���Ƿ�Ҫ"д"
    mem_wdata_i,//mem��д"����"
    mem_wd_i,   //mem��д"��ַ"
//---------------------------------------------------------------------
    reg1_data_i,//�˿�1��ȡ��"����"�Ĵ���
    reg2_data_i,//�˿�2��ȡ��"����"�Ĵ���
    //�͵�regfile����Ϣ
    reg1_read_o,//�˿�1��ȡ"ʹ��"
    reg2_read_o,//�˿�2��ȡ"ʹ��"
    reg1_addr_o,//�˿�1��ȡ"��ַ"
    reg2_addr_o,//�˿�2��ȡ"��ַ"
    //�͵�ִ�н׶ε���Ϣ
    aluop_o,    //����������
    alusel_o,   //��������
    reg1_o,     //Դ������1
    reg2_o,     //Դ������2
    wd_o,       //д��ַ
    wreg_o      //�Ƿ���д��Ŀ�ļĴ���
);

//����ʵ��
input wire  rst;    //��λ�ź�
input wire[`InstAddrBus]    pc_i;
input wire[`InstBus]        inst_i;
//---------------------------------------------------------------------
//����ǰ�ƣ���ȡex�κ�mem��"д"�������Ȼ������Ҫ����ʱ�����ֱ�ӻ�ȡ����
//����ִ�н׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
input wire              ex_wreg_i;
input wire[`RegBus]     ex_wdata_i;
input wire[`RegAddrBus] ex_wd_i;
//���ڷô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
input wire              mem_wreg_i;
input wire[`RegBus]     mem_wdata_i;
input wire[`RegAddrBus] mem_wd_i;
//---------------------------------------------------------------------
input wire[`RegBus]     reg1_data_i;
input wire[`RegBus]     reg2_data_i;
//�͵�regfile����Ϣ
output reg              reg1_read_o;
output reg              reg2_read_o;     
output reg[`RegAddrBus] reg1_addr_o;
output reg[`RegAddrBus] reg2_addr_o; 	      
//�͵�ִ�н׶ε���Ϣ
output reg[`AluOpBus]   aluop_o;
output reg[`AluSelBus]  alusel_o;
output reg[`RegBus]     reg1_o;
output reg[`RegBus]     reg2_o;
output reg[`RegAddrBus] wd_o;
output reg              wreg_o;

//��ָ����зֶδ���
//==================================================
//31:26 | 25:21 | 20:16 | 15-11 | 10:6 | 5:0 |    
//--------------------------------------------    
// op   |       | op4   |       | op2  | op3 |
//--------------------------------------------
// op   |   rs  |  rt   |  rd   | sh   | func| ~ R�� 
// op   |   rs  |  rt   |       im           | ~ I�� 
// op   |          address                   | ~ J�� 
//==================================================
//op��Ӧ�Ļ�������������ʾ
//RegBus-32
wire[5:0] op = inst_i[31:26]; 
wire[4:0] op2 = inst_i[10:6]; 
wire[5:0] op3 = inst_i[5:0];
wire[4:0] op4 = inst_i[20:16];
reg[`RegBus]	imm;
reg instvalid;  //ָ����Ч

//����߼���·
always @ (*) begin	
    if (rst == `RstEnable) begin //��λ--�ù���Ĺ��㣬ָ��͵�ַ����ΪXX_NOP
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        instvalid <= `InstValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= 32'h0;			
    end else begin //����Ҫ��λ
        //ͬһ����Ĭ��ֵ��Ĭ����R��ָ�ʵ��ִ�з���ʱ��ͬ�ط������ı�
        aluop_o <= `EXE_NOP_OP;     //���������ͳ�ʼ��ΪNOP
        alusel_o <= `EXE_RES_NOP;   //�������ͳ�ʼ��ΪNOP
        wd_o <= inst_i[15:11];      //Ĭ��[15:11],��rdΪд��ַ(��ͬ����ָ��д��ַ��ͬ,��ָ��ʵ�ֵ�ʱ���)
        wreg_o <= `WriteDisable;    //Ĭ��"дʹ��"Ϊ0������д
        instvalid <= `InstInvalid;	//Ĭ��ָ����Ч
        reg1_read_o <= 1'b0;        //Ĭ�϶˿�1"��ʹ��"Ϊ0�������
        reg2_read_o <= 1'b0;        //Ĭ�϶˿�2"��ʹ��"Ϊ0�������
        reg1_addr_o <= inst_i[25:21];   //Ĭ�϶˿�1"����ַ"Ϊ[25:21](��R��ʱ��rs)
        reg2_addr_o <= inst_i[20:16];	//Ĭ�϶˿�2"����ַ"Ϊ[20:16](��R��ʱ��rt)
        imm <= `ZeroWord;
        case (op) 
        //����У�SPECIAL��ORI��ANDI��XORI��LUI��SLTI��SLTIU��ADDI��ADDIU��SPECIAL2 ��10��
        `EXE_SPECIAL_INST:		begin //0
            case (op2) //����У�"00000" ��1��
                5'b00000:			begin
                    case (op3) 
                    //�����: OR��AND��XOR��NOR��SLLV��SRLV��SRAV��MFHI��MFLO��MTHI��MTLO��MOVN
                    //MOVZ��SLT��SLTU��ADD��ADDU��SUB��SUBU��MULT��MULTU ��21��
                        `EXE_OR:	begin //100101
                            wreg_o <= `WriteEnable;		//��д
                            aluop_o <= `EXE_OR_OP;      //����������=OR
                            alusel_o <= `EXE_RES_LOGIC; //��������=�߼�����
                            reg1_read_o <= 1'b1;	    //��Ҫ��rs
                            reg2_read_o <= 1'b1;        //��Ҫ��rt
                            instvalid <= `InstValid;	//ָ����Ч
                            end  
                        `EXE_AND:	begin
                            wreg_o <= `WriteEnable;		//��д
                            aluop_o <= `EXE_AND_OP;
                            alusel_o <= `EXE_RES_LOGIC;	  
                            reg1_read_o <= 1'b1;	    //��Ҫ��rs
                            reg2_read_o <= 1'b1;	    //��Ҫ��rt
                            instvalid <= `InstValid;	//ָ����Ч
                            end  	
                        `EXE_XOR:	begin
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_XOR_OP;
                            alusel_o <= `EXE_RES_LOGIC; //��������=�߼�����
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;	
                            instvalid <= `InstValid;	
                            end  				
                        `EXE_NOR:	begin
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_NOR_OP;
                            alusel_o <= `EXE_RES_LOGIC;	//��������=�߼�����
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;	
                            instvalid <= `InstValid;	
                            end 
                        `EXE_SLLV: begin //rd <- rt << rs[4:0](logic) ~shfit logic left v(rs�ĵ�4λ)
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SLL_OP;
                            alusel_o <= `EXE_RES_SHIFT;	//��������=��λ����	
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end 
                        `EXE_SRLV: begin //rd <- rt >> rs[4:0](logic) ~shfit logic right v(rs�ĵ�4λ)
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SRL_OP;
                            alusel_o <= `EXE_RES_SHIFT;	//��������=��λ����
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end 					
                        `EXE_SRAV: begin //rd <- rt >> rs[4:0](arithmetic) ~shfit arithmetic right v(rs�ĵ�4λ)
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SRA_OP;
                            alusel_o <= `EXE_RES_SHIFT;	//��������=��λ����
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;			
                            end
                        `EXE_MFHI: begin //move from hi
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_MFHI_OP;
                            alusel_o <= `EXE_RES_MOVE;  //��������=�ƶ�����
                            reg1_read_o <= 1'b0;	
                            reg2_read_o <= 1'b0;
                            instvalid <= `InstValid;	
                            end
                        `EXE_MFLO: begin //move from lo
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_MFLO_OP;
                            alusel_o <= `EXE_RES_MOVE;  //��������=�ƶ�����
                            reg1_read_o <= 1'b0;	
                            reg2_read_o <= 1'b0;
                            instvalid <= `InstValid;	
                            end
                        `EXE_MTHI: begin //move to hi
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_MTHI_OP;    //����������=move to hi
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b0; 
                            instvalid <= `InstValid;	
                            end
                        `EXE_MTLO: begin //move to lo
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_MTLO_OP;   //����������=move to lo
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b0; 
                            instvalid <= `InstValid;	
                            end
                        `EXE_MOVN: begin   //move if not zero
                            aluop_o <= `EXE_MOVN_OP;   //����������=move if not zero
                            alusel_o <= `EXE_RES_MOVE; //��������=�ƶ�����
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;
                            if(reg2_o != `ZeroWord) begin
                                wreg_o <= `WriteEnable;
                            end else begin
                                wreg_o <= `WriteDisable;
                            end
                            end
                        `EXE_MOVZ: begin //move if zero
                            aluop_o <= `EXE_MOVZ_OP;    //����������=move if zero
                            alusel_o <= `EXE_RES_MOVE;  //��������=�ƶ�����
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;
                            if(reg2_o == `ZeroWord) begin
                                wreg_o <= `WriteEnable;
                            end else begin
                                wreg_o <= `WriteDisable;
                            end		  							
                            end
                        `EXE_SLT: begin  //rd <- (rs < rt) �з���
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SLT_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;	//������	
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end
                        `EXE_SLTU: begin //rd <- (rs < rt) ���з���
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SLTU_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;	//������
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end
                        `EXE_ADD: begin //�з��ż� add rd,rs,rt ��rd <- rs+rt
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_ADD_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;	//������
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end
                        `EXE_ADDU: begin //�޷��ż� addu rd,rs,rt��rd <- rs+rt
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_ADDU_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;	//������
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end
                        `EXE_SUB: begin //�з��ż� sub rd,rs,rt
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SUB_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;	//������
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end
                        `EXE_SUBU: begin //�޷��ż� subu rd,rs,rt
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SUBU_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;	//������
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end
                        `EXE_MULT: begin //�з��ų� mul,rd,rs,st��rd <- rs * rt
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_MULT_OP;
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1; 
                            instvalid <= `InstValid;	
                            end
                        `EXE_MULTU: begin //�޷��ų� mulu,rd,rs,st��rd <- rs * rt
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_MULTU_OP;
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1; 
                            instvalid <= `InstValid;	
                            end 
                        `EXE_DIV: begin //�޷��ų� mulu,rd,rs,st��rd <- rs * rt
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_DIV_OP;
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1; 
                            instvalid <= `InstValid;	
                            end 
                        `EXE_DIVU: begin //�޷��ų� mulu,rd,rs,st��rd <- rs * rt
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_DIVU_OP;
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1; 
                            instvalid <= `InstValid;	
                            end 
                            											  											
                        default:	begin
                            end
                        endcase
                    end
                    default: begin
                        end
                endcase	
            end									  
        //==================================================
        //31:26 | 25:21 | 20:16 | 15-11 | 10:6 | 5:0 |    
        //--------------------------------------------    
        // op   |       | op4   |       | op2  | op3 |
        //--------------------------------------------
        // op   |   rs  |  rt   |  rd   | sh   | func| ~ R��
        // op   |   rs  |  rt   |       im           | ~ I�� 
        // op   |          address                   | ~ J�� 
        //==================================================
        //I��ָ�Ĭ�ϵ�д�Ĵ�������Ҫ���ģ���Ϊrt
        `EXE_ORI:			begin   //ORIָ�� 001101 ori rs,rt,immediate 
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_OR_OP;
            alusel_o <= `EXE_RES_LOGIC; //�߼�����
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//������������չ	  	
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//������������չ	
            wd_o <= inst_i[20:16];       //����д�Ĵ���Ϊrt
            instvalid <= `InstValid;	
        end
        `EXE_ANDI:			begin
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_AND_OP;
            alusel_o <= `EXE_RES_LOGIC;	 //�߼�����
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//������������չ          
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//������������չ		
            wd_o <= inst_i[20:16];		 //����д�Ĵ���Ϊrt
            instvalid <= `InstValid;	
            end	 	
        `EXE_XORI:			begin
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_XOR_OP;
            alusel_o <= `EXE_RES_LOGIC;	//�߼�����
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//������������չ          
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//������������չ		
            wd_o <= inst_i[20:16];		 //����д�Ĵ�����Ϊrt
            instvalid <= `InstValid;	
            end	 		
        `EXE_LUI:			begin //lui rt,immediate; rt <- immediate || $0 ��Ĵ�����Ϊ0
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_OR_OP;      //��������Ϊor��luiָ����oriָ��ʵ����ͬ
            alusel_o <= `EXE_RES_LOGIC; //�߼�����
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//������������չ          
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//������������չ		
            wd_o <= inst_i[20:16];		//��Ϊrt
            instvalid <= `InstValid;	
            end			
        `EXE_SLTI:			begin
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_SLT_OP;
            alusel_o <= `EXE_RES_ARITHMETIC; //��������
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//������������չ          
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//������������չ		
            wd_o <= inst_i[20:16];		    //��Ϊrt
            instvalid <= `InstValid;	
            end
        `EXE_SLTIU:			begin
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_SLTU_OP;
            alusel_o <= `EXE_RES_ARITHMETIC;//�������� 
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//������������չ          
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//������������չ	
            wd_o <= inst_i[20:16];		    //��Ϊrt
            instvalid <= `InstValid;	
            end
        `EXE_ADDI:			begin
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_ADDI_OP;
            alusel_o <= `EXE_RES_ARITHMETIC;//��������
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//������������չ          
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//������������չ		
            wd_o <= inst_i[20:16];		    //��Ϊrt
            instvalid <= `InstValid;	
            end
        `EXE_ADDIU:			begin
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_ADDIU_OP;
            alusel_o <= `EXE_RES_ARITHMETIC;//��������
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//������������չ          
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//������������չ		
            wd_o <= inst_i[20:16];		    //��Ϊrt
            instvalid <= `InstValid;	
            end
        `EXE_SPECIAL2_INST:		begin //011100
                case ( op3 )
                    `EXE_CLZ:		begin //ͳ�Ƹ�λ����zero�ĸ��� clz rd��rs��rd <- count_leading_zeros rs
                        wreg_o <= `WriteEnable;		
                        aluop_o <= `EXE_CLZ_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC; 
                        reg1_read_o <= 1'b1;	
                        reg2_read_o <= 1'b0;	  	
                        instvalid <= `InstValid;	
                        end
                    `EXE_CLO:		begin //ͳ�Ƹ�λ����one�ĸ��� clo rd��rs��rd <- count_leading_ones rs
                        wreg_o <= `WriteEnable;		
                        aluop_o <= `EXE_CLO_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC; 
                        reg1_read_o <= 1'b1;	
                        reg2_read_o <= 1'b0;	  	
                        instvalid <= `InstValid;	
                        end
                    `EXE_MUL:		begin //mul rd��rs��st; rd �� rs��rt
                        wreg_o <= `WriteEnable;		
                        aluop_o <= `EXE_MUL_OP;
                        alusel_o <= `EXE_RES_MUL; 
                        reg1_read_o <= 1'b1;	
                        reg2_read_o <= 1'b1;	
                        instvalid <= `InstValid;	  			
                        end
                    default:	begin
                        end
                endcase 
            end																		  	
        default:			begin
            end
        endcase
        //==================================================
        //31:26 | 25:21 | 20:16 | 15-11 | 10:6 | 5:0 |    
        //--------------------------------------------    
        // op   |       | op4   |       | op2  | op3 |
        //--------------------------------------------
        // op   |   rs  |  rt   |  rd   | shamt| func| ~ R��  �����sh��Ӧ������λָ���е�sa
        // op   |   rs  |  rt   |       im           | ~ I�� 
        // op   |          address                   | ~ J�� 
        //==================================================
        if (inst_i[31:21] == 11'b00000000000) begin
            if (op3 == `EXE_SLL) begin //sll rd,rt,sa; rd <- rt<<sa(logic) ����saλ
                wreg_o <= `WriteEnable;		
                aluop_o <= `EXE_SLL_OP;
                alusel_o <= `EXE_RES_SHIFT; //��λ����
                reg1_read_o <= 1'b0;	
                reg2_read_o <= 1'b1;	  	
                imm[4:0] <= inst_i[10:6];   //������Ϊshamt
                wd_o <= inst_i[15:11];      //д�Ĵ���Ϊrd
                instvalid <= `InstValid;	
            end else if ( op3 == `EXE_SRL ) begin //srl rd,rt,sa; rd <- rt>>sa(logic) ����saλ
                wreg_o <= `WriteEnable;		
                aluop_o <= `EXE_SRL_OP;
                alusel_o <= `EXE_RES_SHIFT; //��λ����
                reg1_read_o <= 1'b0;	
                reg2_read_o <= 1'b1;	  	//д�Ĵ���Ϊrd
                imm[4:0] <= inst_i[10:6];	//������Ϊshamt
                wd_o <= inst_i[15:11];
                instvalid <= `InstValid;	
            end else if ( op3 == `EXE_SRA ) begin
                wreg_o <= `WriteEnable;		
                aluop_o <= `EXE_SRA_OP;
                alusel_o <= `EXE_RES_SHIFT; //��λ����
                reg1_read_o <= 1'b0;	
                reg2_read_o <= 1'b1;	  	//д�Ĵ���Ϊrd
                imm[4:0] <= inst_i[10:6];	//������Ϊshamt
                wd_o <= inst_i[15:11];
                instvalid <= `InstValid;	
                end
        end		  
        
    end     
end
//����߼���·
//func�����read1������
always @ (*) begin
    if(rst == `RstEnable) begin //��λ
        reg1_o <= `ZeroWord;	
    //����ǰ�ƣ����id��Ҫ������ʱex��Ҫд�����Ҷ��ߵ�ַ��ͬ�������ֱ�ӵõ����ݣ�
    //ex��ǰ��Ϊ������ˮ�ߣ�ex�ε�����Ҫ��mem�ε�"��"
    end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
        reg1_o <= ex_wdata_i; 
    //����ǰ�ƣ����id��Ҫ������ʱmem��Ҫд�����Ҷ��ߵ�ַ��ͬ�������ֱ�ӵõ�����
    end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o)) begin
        reg1_o <= mem_wdata_i; 		
    //����ɶ�����ָ���Ĵ����ж�ȡȡ����	
    end else if(reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i;
    //���ɶ���ֵΪ������
    end else if(reg1_read_o == 1'b0) begin
        reg1_o <= imm;
    //����Ϊ0
    end else begin
        reg1_o <= `ZeroWord;
    end
end

//����߼���·
//func�����read2������
always @ (*) begin
    if(rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
    //����ǰ�ƣ����id��Ҫ������ʱex��Ҫд�����Ҷ��ߵ�ַ��ͬ�������ֱ�ӵõ����ݣ�
    //ex��ǰ��Ϊ������ˮ�ߣ�ex�ε�����Ҫ��mem�ε�"��"
    end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o)) begin
        reg2_o <= ex_wdata_i; 
    //����ǰ�ƣ����id��Ҫ������ʱmem��Ҫд�����Ҷ��ߵ�ַ��ͬ�������ֱ�ӵõ�����
    end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o)) begin
        reg2_o <= mem_wdata_i;	
    //����ɶ�����ָ���Ĵ����ж�ȡȡ����		
    end else if(reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i;
    //���ɶ���ֵΪ������
    end else if(reg2_read_o == 1'b0) begin
        reg2_o <= imm;
    end else begin //����Ϊ0
        reg2_o <= `ZeroWord;
    end
end

endmodule