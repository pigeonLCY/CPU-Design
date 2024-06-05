//id 译码
`include "defines.v"

module id(
//名称定义
    rst,    //复位信号
    //xx_i：输入到id段的数据
    //xx_o：从id段输出的数据
    pc_i,   //pc
    inst_i, //取得的指令
//---------------------------------------------------------------------
//数据前推：获取ex段和mem段"写"的情况，然后在需要读的时候可以直接获取数据
    //处于执行阶段的指令要写入的目的寄存器信息
    ex_wreg_i,  //ex段是否要"写"
    ex_wdata_i, //ex段写"数据"
    ex_wd_i,    //ex段写"地址"
    //处于访存阶段的指令要写入的目的寄存器信息
    mem_wreg_i, //mem段是否要"写"
    mem_wdata_i,//mem段写"数据"
    mem_wd_i,   //mem段写"地址"
//---------------------------------------------------------------------
    reg1_data_i,//端口1读取的"数据"寄存器
    reg2_data_i,//端口2读取的"数据"寄存器
    //送到regfile的信息
    reg1_read_o,//端口1读取"使能"
    reg2_read_o,//端口2读取"使能"
    reg1_addr_o,//端口1读取"地址"
    reg2_addr_o,//端口2读取"地址"
    //送到执行阶段的信息
    aluop_o,    //运算子类型
    alusel_o,   //运算类型
    reg1_o,     //源操作数1
    reg2_o,     //源操作数2
    wd_o,       //写地址
    wreg_o      //是否有写的目的寄存器
);

//类型实现
input wire  rst;    //复位信号
input wire[`InstAddrBus]    pc_i;
input wire[`InstBus]        inst_i;
//---------------------------------------------------------------------
//数据前推：获取ex段和mem段"写"的情况，然后在需要读的时候可以直接获取数据
//处于执行阶段的指令要写入的目的寄存器信息
input wire              ex_wreg_i;
input wire[`RegBus]     ex_wdata_i;
input wire[`RegAddrBus] ex_wd_i;
//处于访存阶段的指令要写入的目的寄存器信息
input wire              mem_wreg_i;
input wire[`RegBus]     mem_wdata_i;
input wire[`RegAddrBus] mem_wd_i;
//---------------------------------------------------------------------
input wire[`RegBus]     reg1_data_i;
input wire[`RegBus]     reg2_data_i;
//送到regfile的信息
output reg              reg1_read_o;
output reg              reg2_read_o;     
output reg[`RegAddrBus] reg1_addr_o;
output reg[`RegAddrBus] reg2_addr_o; 	      
//送到执行阶段的信息
output reg[`AluOpBus]   aluop_o;
output reg[`AluSelBus]  alusel_o;
output reg[`RegBus]     reg1_o;
output reg[`RegBus]     reg2_o;
output reg[`RegAddrBus] wd_o;
output reg              wreg_o;

//将指令进行分段处理
//==================================================
//31:26 | 25:21 | 20:16 | 15-11 | 10:6 | 5:0 |    
//--------------------------------------------    
// op   |       | op4   |       | op2  | op3 |
//--------------------------------------------
// op   |   rs  |  rt   |  rd   | sh   | func| ~ R类 
// op   |   rs  |  rt   |       im           | ~ I类 
// op   |          address                   | ~ J类 
//==================================================
//op对应的划分区域如上所示
//RegBus-32
wire[5:0] op = inst_i[31:26]; 
wire[4:0] op2 = inst_i[10:6]; 
wire[5:0] op3 = inst_i[5:0];
wire[4:0] op4 = inst_i[20:16];
reg[`RegBus]	imm;
reg instvalid;  //指令有效

//组合逻辑电路
always @ (*) begin	
    if (rst == `RstEnable) begin //复位--该归零的归零，指令和地址都设为XX_NOP
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
    end else begin //不需要复位
        //同一设置默认值，默认是R类指令，实际执行翻译时不同地方再做改变
        aluop_o <= `EXE_NOP_OP;     //运算子类型初始化为NOP
        alusel_o <= `EXE_RES_NOP;   //运算类型初始化为NOP
        wd_o <= inst_i[15:11];      //默认[15:11],即rd为写地址(不同类型指令写地址不同,在指令实现的时候改)
        wreg_o <= `WriteDisable;    //默认"写使能"为0，不许写
        instvalid <= `InstInvalid;	//默认指令有效
        reg1_read_o <= 1'b0;        //默认端口1"读使能"为0，不许读
        reg2_read_o <= 1'b0;        //默认端口2"读使能"为0，不许读
        reg1_addr_o <= inst_i[25:21];   //默认端口1"读地址"为[25:21](即R类时的rs)
        reg2_addr_o <= inst_i[20:16];	//默认端口2"读地址"为[20:16](即R类时的rt)
        imm <= `ZeroWord;
        case (op) 
        //情况有：SPECIAL、ORI、ANDI、XORI、LUI、SLTI、SLTIU、ADDI、ADDIU、SPECIAL2 共10种
        `EXE_SPECIAL_INST:		begin //0
            case (op2) //情况有："00000" 共1种
                5'b00000:			begin
                    case (op3) 
                    //情况有: OR、AND、XOR、NOR、SLLV、SRLV、SRAV、MFHI、MFLO、MTHI、MTLO、MOVN
                    //MOVZ、SLT、SLTU、ADD、ADDU、SUB、SUBU、MULT、MULTU 共21种
                        `EXE_OR:	begin //100101
                            wreg_o <= `WriteEnable;		//可写
                            aluop_o <= `EXE_OR_OP;      //运算子类型=OR
                            alusel_o <= `EXE_RES_LOGIC; //运算类型=逻辑运算
                            reg1_read_o <= 1'b1;	    //需要读rs
                            reg2_read_o <= 1'b1;        //需要读rt
                            instvalid <= `InstValid;	//指令有效
                            end  
                        `EXE_AND:	begin
                            wreg_o <= `WriteEnable;		//可写
                            aluop_o <= `EXE_AND_OP;
                            alusel_o <= `EXE_RES_LOGIC;	  
                            reg1_read_o <= 1'b1;	    //需要读rs
                            reg2_read_o <= 1'b1;	    //需要读rt
                            instvalid <= `InstValid;	//指令有效
                            end  	
                        `EXE_XOR:	begin
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_XOR_OP;
                            alusel_o <= `EXE_RES_LOGIC; //运算类型=逻辑运算
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;	
                            instvalid <= `InstValid;	
                            end  				
                        `EXE_NOR:	begin
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_NOR_OP;
                            alusel_o <= `EXE_RES_LOGIC;	//运算类型=逻辑运算
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;	
                            instvalid <= `InstValid;	
                            end 
                        `EXE_SLLV: begin //rd <- rt << rs[4:0](logic) ~shfit logic left v(rs的低4位)
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SLL_OP;
                            alusel_o <= `EXE_RES_SHIFT;	//运算类型=移位运算	
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end 
                        `EXE_SRLV: begin //rd <- rt >> rs[4:0](logic) ~shfit logic right v(rs的低4位)
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SRL_OP;
                            alusel_o <= `EXE_RES_SHIFT;	//运算类型=移位运算
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end 					
                        `EXE_SRAV: begin //rd <- rt >> rs[4:0](arithmetic) ~shfit arithmetic right v(rs的低4位)
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SRA_OP;
                            alusel_o <= `EXE_RES_SHIFT;	//运算类型=移位运算
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;			
                            end
                        `EXE_MFHI: begin //move from hi
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_MFHI_OP;
                            alusel_o <= `EXE_RES_MOVE;  //运算类型=移动运算
                            reg1_read_o <= 1'b0;	
                            reg2_read_o <= 1'b0;
                            instvalid <= `InstValid;	
                            end
                        `EXE_MFLO: begin //move from lo
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_MFLO_OP;
                            alusel_o <= `EXE_RES_MOVE;  //运算类型=移动运算
                            reg1_read_o <= 1'b0;	
                            reg2_read_o <= 1'b0;
                            instvalid <= `InstValid;	
                            end
                        `EXE_MTHI: begin //move to hi
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_MTHI_OP;    //运算子类型=move to hi
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b0; 
                            instvalid <= `InstValid;	
                            end
                        `EXE_MTLO: begin //move to lo
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_MTLO_OP;   //运算子类型=move to lo
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b0; 
                            instvalid <= `InstValid;	
                            end
                        `EXE_MOVN: begin   //move if not zero
                            aluop_o <= `EXE_MOVN_OP;   //运算子类型=move if not zero
                            alusel_o <= `EXE_RES_MOVE; //运算类型=移动运算
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
                            aluop_o <= `EXE_MOVZ_OP;    //运算子类型=move if zero
                            alusel_o <= `EXE_RES_MOVE;  //运算类型=移动运算
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;
                            if(reg2_o == `ZeroWord) begin
                                wreg_o <= `WriteEnable;
                            end else begin
                                wreg_o <= `WriteDisable;
                            end		  							
                            end
                        `EXE_SLT: begin  //rd <- (rs < rt) 有符号
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SLT_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;	//算数类	
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end
                        `EXE_SLTU: begin //rd <- (rs < rt) 无有符号
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SLTU_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;	//算数类
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end
                        `EXE_ADD: begin //有符号加 add rd,rs,rt ；rd <- rs+rt
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_ADD_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;	//算数类
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end
                        `EXE_ADDU: begin //无符号加 addu rd,rs,rt；rd <- rs+rt
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_ADDU_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;	//算数类
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end
                        `EXE_SUB: begin //有符号减 sub rd,rs,rt
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SUB_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;	//算数类
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end
                        `EXE_SUBU: begin //无符号减 subu rd,rs,rt
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SUBU_OP;
                            alusel_o <= `EXE_RES_ARITHMETIC;	//算数类
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                            end
                        `EXE_MULT: begin //有符号乘 mul,rd,rs,st；rd <- rs * rt
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_MULT_OP;
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1; 
                            instvalid <= `InstValid;	
                            end
                        `EXE_MULTU: begin //无符号乘 mulu,rd,rs,st；rd <- rs * rt
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_MULTU_OP;
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1; 
                            instvalid <= `InstValid;	
                            end 
                        `EXE_DIV: begin //无符号乘 mulu,rd,rs,st；rd <- rs * rt
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_DIV_OP;
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1; 
                            instvalid <= `InstValid;	
                            end 
                        `EXE_DIVU: begin //无符号乘 mulu,rd,rs,st；rd <- rs * rt
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
        // op   |   rs  |  rt   |  rd   | sh   | func| ~ R类
        // op   |   rs  |  rt   |       im           | ~ I类 
        // op   |          address                   | ~ J类 
        //==================================================
        //I类指令，默认的写寄存器号需要更改，改为rt
        `EXE_ORI:			begin   //ORI指令 001101 ori rs,rt,immediate 
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_OR_OP;
            alusel_o <= `EXE_RES_LOGIC; //逻辑运算
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//立即数进行扩展	  	
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//立即数进行扩展	
            wd_o <= inst_i[20:16];       //更改写寄存器为rt
            instvalid <= `InstValid;	
        end
        `EXE_ANDI:			begin
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_AND_OP;
            alusel_o <= `EXE_RES_LOGIC;	 //逻辑运算
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//立即数进行扩展          
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//立即数进行扩展		
            wd_o <= inst_i[20:16];		 //更改写寄存器为rt
            instvalid <= `InstValid;	
            end	 	
        `EXE_XORI:			begin
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_XOR_OP;
            alusel_o <= `EXE_RES_LOGIC;	//逻辑运算
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//立即数进行扩展          
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//立即数进行扩展		
            wd_o <= inst_i[20:16];		 //更改写寄存器号为rt
            instvalid <= `InstValid;	
            end	 		
        `EXE_LUI:			begin //lui rt,immediate; rt <- immediate || $0 零寄存器恒为0
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_OR_OP;      //运算类型为or，lui指令与ori指令实现相同
            alusel_o <= `EXE_RES_LOGIC; //逻辑运算
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//立即数进行扩展          
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//立即数进行扩展		
            wd_o <= inst_i[20:16];		//改为rt
            instvalid <= `InstValid;	
            end			
        `EXE_SLTI:			begin
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_SLT_OP;
            alusel_o <= `EXE_RES_ARITHMETIC; //算数运算
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//立即数进行扩展          
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//立即数进行扩展		
            wd_o <= inst_i[20:16];		    //改为rt
            instvalid <= `InstValid;	
            end
        `EXE_SLTIU:			begin
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_SLTU_OP;
            alusel_o <= `EXE_RES_ARITHMETIC;//算数运算 
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//立即数进行扩展          
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//立即数进行扩展	
            wd_o <= inst_i[20:16];		    //改为rt
            instvalid <= `InstValid;	
            end
        `EXE_ADDI:			begin
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_ADDI_OP;
            alusel_o <= `EXE_RES_ARITHMETIC;//算数运算
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//立即数进行扩展          
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//立即数进行扩展		
            wd_o <= inst_i[20:16];		    //改为rt
            instvalid <= `InstValid;	
            end
        `EXE_ADDIU:			begin
            wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_ADDIU_OP;
            alusel_o <= `EXE_RES_ARITHMETIC;//算数运算
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
            if (inst_i[15] == 1) begin
                 imm <= {16'hffff, inst_i[15:0]};//立即数进行扩展          
            end else begin 
                imm <= {16'h0, inst_i[15:0]}; end//立即数进行扩展		
            wd_o <= inst_i[20:16];		    //改为rt
            instvalid <= `InstValid;	
            end
        `EXE_SPECIAL2_INST:		begin //011100
                case ( op3 )
                    `EXE_CLZ:		begin //统计高位连续zero的个数 clz rd，rs；rd <- count_leading_zeros rs
                        wreg_o <= `WriteEnable;		
                        aluop_o <= `EXE_CLZ_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC; 
                        reg1_read_o <= 1'b1;	
                        reg2_read_o <= 1'b0;	  	
                        instvalid <= `InstValid;	
                        end
                    `EXE_CLO:		begin //统计高位连续one的个数 clo rd，rs；rd <- count_leading_ones rs
                        wreg_o <= `WriteEnable;		
                        aluop_o <= `EXE_CLO_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC; 
                        reg1_read_o <= 1'b1;	
                        reg2_read_o <= 1'b0;	  	
                        instvalid <= `InstValid;	
                        end
                    `EXE_MUL:		begin //mul rd，rs，st; rd ← rs×rt
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
        // op   |   rs  |  rt   |  rd   | shamt| func| ~ R类  这里的sh对应下面移位指令中的sa
        // op   |   rs  |  rt   |       im           | ~ I类 
        // op   |          address                   | ~ J类 
        //==================================================
        if (inst_i[31:21] == 11'b00000000000) begin
            if (op3 == `EXE_SLL) begin //sll rd,rt,sa; rd <- rt<<sa(logic) 左移sa位
                wreg_o <= `WriteEnable;		
                aluop_o <= `EXE_SLL_OP;
                alusel_o <= `EXE_RES_SHIFT; //移位运算
                reg1_read_o <= 1'b0;	
                reg2_read_o <= 1'b1;	  	
                imm[4:0] <= inst_i[10:6];   //立即数为shamt
                wd_o <= inst_i[15:11];      //写寄存器为rd
                instvalid <= `InstValid;	
            end else if ( op3 == `EXE_SRL ) begin //srl rd,rt,sa; rd <- rt>>sa(logic) 右移sa位
                wreg_o <= `WriteEnable;		
                aluop_o <= `EXE_SRL_OP;
                alusel_o <= `EXE_RES_SHIFT; //移位运算
                reg1_read_o <= 1'b0;	
                reg2_read_o <= 1'b1;	  	//写寄存器为rd
                imm[4:0] <= inst_i[10:6];	//立即数为shamt
                wd_o <= inst_i[15:11];
                instvalid <= `InstValid;	
            end else if ( op3 == `EXE_SRA ) begin
                wreg_o <= `WriteEnable;		
                aluop_o <= `EXE_SRA_OP;
                alusel_o <= `EXE_RES_SHIFT; //移位运算
                reg1_read_o <= 1'b0;	
                reg2_read_o <= 1'b1;	  	//写寄存器为rd
                imm[4:0] <= inst_i[10:6];	//立即数为shamt
                wd_o <= inst_i[15:11];
                instvalid <= `InstValid;	
                end
        end		  
        
    end     
end
//组合逻辑电路
//func：获得read1的数据
always @ (*) begin
    if(rst == `RstEnable) begin //复位
        reg1_o <= `ZeroWord;	
    //数据前推：如果id段要读，此时ex段要写，并且二者地址相同，则可以直接得到数据，
    //ex在前因为根据流水线，ex段的数据要比mem段的"新"
    end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
        reg1_o <= ex_wdata_i; 
    //数据前推：如果id段要读，此时mem段要写，并且二者地址相同，则可以直接得到数据
    end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o)) begin
        reg1_o <= mem_wdata_i; 		
    //如果可读，从指定寄存器中读取取数据	
    end else if(reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i;
    //不可读赋值为立即数
    end else if(reg1_read_o == 1'b0) begin
        reg1_o <= imm;
    //否则为0
    end else begin
        reg1_o <= `ZeroWord;
    end
end

//组合逻辑电路
//func：获得read2的数据
always @ (*) begin
    if(rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
    //数据前推：如果id段要读，此时ex段要写，并且二者地址相同，则可以直接得到数据，
    //ex在前因为根据流水线，ex段的数据要比mem段的"新"
    end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o)) begin
        reg2_o <= ex_wdata_i; 
    //数据前推：如果id段要读，此时mem段要写，并且二者地址相同，则可以直接得到数据
    end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o)) begin
        reg2_o <= mem_wdata_i;	
    //如果可读，从指定寄存器中读取取数据		
    end else if(reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i;
    //不可读赋值为立即数
    end else if(reg2_read_o == 1'b0) begin
        reg2_o <= imm;
    end else begin //否则为0
        reg2_o <= `ZeroWord;
    end
end

endmodule