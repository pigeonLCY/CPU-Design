//ex 执行

`include "defines.v"

module ex(
	rst,        //复位信号
    aluop_i,    //运算子类
    alusel_i,   //运算主类
    reg1_i,     //ex段接收到的源操作数1
    reg2_i,     //ex段接收到的源操作数2
    wd_i,       //ex段接收到的写地址
    wreg_i,     //ex段接收到的写使能
    hi_i,       //HI寄存器
    lo_i,       //LO寄存器
//-----------------------------------------------------
//检测wb、mem段对于hilo的访问，发现hilo存在的相关
    wb_hi_i,    //wb段写hi的值
    wb_lo_i,    //wb段写lo的值
    wb_whilo_i, //wb段是否要写hilo

    mem_hi_i,   //mem段写hi的值
    mem_lo_i,   //mem段写lo的值
    mem_whilo_i,//mem段是否要写hilo
//-----------------------------------------------------
    wd_o,       //ex段"写地址"
    wreg_o,     //ex段"写使能"
    wdata_o,    //ex段"写数据"
    hi_o,       //ex段写hi的值
    lo_o,       //ex段写lo的值
    whilo_o	    //ex段是否要写hilo
);
//========================================================
//类型定义
input wire  rst;//复位信号
input wire[`AluOpBus]   aluop_i;    //运算子类
input wire[`AluSelBus]  alusel_i;   //运算主类
input wire[`RegBus]     reg1_i;     //ex段接收到的源操作数1
input wire[`RegBus]     reg2_i;     //ex段接收到的源操作数2
input wire[`RegAddrBus] wd_i;       //ex段接收到的写地址
input wire              wreg_i;     //ex段接收到的写使能
input wire[`RegBus]     hi_i;       //HI寄存器
input wire[`RegBus]     lo_i;       //LO寄存器

input wire[`RegBus]     wb_hi_i;    //wb段写hi的值
input wire[`RegBus]     wb_lo_i;    //wb段写lo的值
input wire              wb_whilo_i; //wb段是否要写hilo
input wire[`RegBus]     mem_hi_i;   //mem段写hi的值
input wire[`RegBus]     mem_lo_i;   //mem段写lo的值
input wire              mem_whilo_i;//mem段是否要写hilo

output reg[`RegAddrBus] wd_o;   //ex段"写地址"
output reg              wreg_o; //ex段"写使能"
output reg[`RegBus]	    wdata_o;//ex段"写数据"
output reg[`RegBus]     hi_o;   //ex段写hi的值
output reg[`RegBus]     lo_o;   //ex段写lo的值
output reg              whilo_o;	//ex段是否要写hilo
//========================================================

reg[`RegBus] logicout;      //逻辑运算结果
reg[`RegBus] shiftres;      //移位运算结果
reg[`RegBus] moveres;       //移动操作结果
reg[`RegBus] arithmeticres; //算数运算结果
reg[`DoubleRegBus] mulres;	//乘法运算结果
reg[`RegBus] divres1; //除法商
reg[`RegBus] divres2; //除法余数
reg[`RegBus] HI;    //hi
reg[`RegBus] LO;    //lo
wire[`RegBus] reg2_i_mux;   //源操作数2的补码
wire[`RegBus] reg1_i_not;   //源操作数2的反码
wire[`RegBus] result_sum;   //"和"结果
wire ov_sum;                //保存溢出情况
wire reg1_eq_reg2;  //r1 是否= r2
wire reg1_lt_reg2;  //r1 是否< r2
wire[`RegBus] opdata1_mult;     //被乘数
wire[`RegBus] opdata2_mult;     //乘数
wire[`DoubleRegBus] hilo_temp;	//乘法结果临时数据


wire[`RegBus] opdata1_div;     //被除数
wire[`RegBus] opdata2_div;     //除数
wire[`RegBus] opdata3_div;     //余数
wire[`RegBus] opdata4_div;     //商



//组合逻辑电路
//func：逻辑运算
always @ (*) begin
    if(rst == `RstEnable) begin //复位
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
                logicout <= `ZeroWord;          //其他
                end
        endcase
    end    
end     



//组合逻辑电路
//func：移位运算
always @ (*) begin
    if(rst == `RstEnable) begin //复位
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
                            //最高位是符号位，用最高位的符号向左移动 （32-reg1_i[4:0]）位，低位现在是0
                            //原来数据右移（reg1_i[4:0]）位，高位是0
                            //二者与运算，高位与符号位相同，低位与数据右移的结果相同
                            //从而实现算数右移
                end
            default:			begin //其他
                shiftres <= `ZeroWord;
                end
        endcase
    end    
end      




//计算源操作数2的补码
//有相减操作的时候需要计算补码，
assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) || (aluop_i == `EXE_SLT_OP) )  ? (~reg2_i)+1 : reg2_i;

//计算"加和"的结果,如果操作是减法这里的结果是减法结果，否则是加法结果
assign result_sum = reg1_i + reg2_i_mux;										 

//查看是否溢出
//以下情况溢出：正+正=负，负+负=正
assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) || ((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));  

//r1是否<r2
assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP)) ? //有符号则计算，无符号则直接比较
                                                ((reg1_i[31] && !reg2_i[31]) || //r1<0 r2>0 ,结果是1
                                                (!reg1_i[31] && !reg2_i[31] && result_sum[31])|| //r1和r2同号，相减结果<0则结果为1
                            (reg1_i[31] && reg2_i[31] && result_sum[31]))
                            :	(reg1_i < reg2_i);

//取反
assign reg1_i_not = ~reg1_i;




//组合逻辑电路
//func:算数运算			
always @ (*) begin
    if(rst == `RstEnable) begin //复位
        arithmeticres <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_SLT_OP, `EXE_SLTU_OP:		begin //r1 < r2
                arithmeticres <= reg1_lt_reg2 ;
                end
            `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP:		begin //加法结果
                arithmeticres <= result_sum; 
                end
            `EXE_SUB_OP, `EXE_SUBU_OP:		begin   //减法结果
                arithmeticres <= result_sum; 
                end		
            `EXE_CLZ_OP:		begin //高位连续zero的个数
                //非常实用的三目运算，如果是if语句的话需要使用大量比较器，性能损耗大
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
            `EXE_CLO_OP:		begin //高位连续one的个数
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

//取得乘法操作的操作数
//有符号乘法
//负数变成源码
assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)) && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;
assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP))  && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;		

assign hilo_temp = opdata1_mult * opdata2_mult;		

//组合逻辑电路
//func：乘法运算
always @ (*) begin
    if(rst == `RstEnable) begin //复位
        mulres <= {`ZeroWord,`ZeroWord};
    //有符号乘法
    end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP))begin
        if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin //两数异号则求补码修正
            mulres <= ~hilo_temp + 1;
        end else begin
            mulres <= hilo_temp;    //同号
        end
    //无符号乘法
    end else begin
            mulres <= hilo_temp;    
    end
end


// 取得除法操作的操作数
// 有符号除法
// 负数变成源码
assign opdata1_div = (((aluop_i == `EXE_DIV_OP) ) && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;
assign opdata2_div = (((aluop_i == `EXE_DIV_OP) )  && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;		

assign opdata3_div = opdata1_div / opdata2_div;
assign opdata4_div = opdata1_div % opdata2_div;
// 执行除法操作
// 使用组合逻辑电路实现除法运算
always @ (*) begin
    if(rst == `RstEnable) begin //复位
        divres1 <= `ZeroWord;
        divres2 <= `ZeroWord;
    //有符号乘法
    end else if ((aluop_i == `EXE_DIV_OP) )begin
        if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin //两数异号则求补码修正
            divres1 <= ~opdata3_div+1;
            divres2 <= ~opdata4_div+1;
        end else begin
            divres1 <= opdata3_div;
            divres2 <= opdata4_div;    //同号
        end
    //无符号乘法
    end else begin
            divres1 <= opdata3_div;
            divres2 <= opdata4_div;
    end
end

//组合逻辑电路
//func：更新hi,lo,解决指令数据相关问题
always @ (*) begin
    if(rst == `RstEnable) begin //复位
        {HI,LO} <= {`ZeroWord,`ZeroWord};
    end else if(mem_whilo_i == `WriteEnable) begin //mem段要写hilo，则将mem段要写的数据写入到hilo中
        {HI,LO} <= {mem_hi_i,mem_lo_i};
    end else if(wb_whilo_i == `WriteEnable) begin //wb要写hilo，则将mem段要写的数据写入到hilo中
        {HI,LO} <= {wb_hi_i,wb_lo_i};
    end else begin  //都没有写，那我可以直接更新计算的数据
        {HI,LO} <= {hi_i,lo_i};			
    end
end	


//组合逻辑电路
//func：移动操作
//处理MFHI、MFLO、MOVN、MOVZ指令
always @ (*) begin
    if(rst == `RstEnable) begin //复位
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


//组合逻辑电路
//func：根据主操作类型选择结果
always @ (*) begin
    wd_o <= wd_i;   
    //加减法溢出则"不写"
    if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) ||  (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
        wreg_o <= `WriteDisable;
    end else begin
        wreg_o <= wreg_i;
    end

    case ( alusel_i ) 
        `EXE_RES_LOGIC:		begin       //逻辑运算结果
            wdata_o <= logicout;
            end
        `EXE_RES_SHIFT:		begin       //移位运算结果
            wdata_o <= shiftres;
            end	 	
        `EXE_RES_MOVE:		begin       //移动操作结果
            wdata_o <= moveres;
            end	 	
        `EXE_RES_ARITHMETIC:    begin   //算数运算结果
            wdata_o <= arithmeticres;
            end
        `EXE_RES_MUL:   begin           //乘法运算结果
            wdata_o <= mulres[31:0];
            end	 	
        default:        begin
            wdata_o <= `ZeroWord;
            end
    endcase
end	


//组合逻辑电路
//func：确定对hilo的操作信息
always @ (*) begin
    if(rst == `RstEnable) begin //复位
        whilo_o <= `WriteDisable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;		
    end else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin //乘法
        whilo_o <= `WriteEnable;
        hi_o <= mulres[63:32];  //高32位放在hi
        lo_o <= mulres[31:0];   //低32位放在lo
    end else if((aluop_i == `EXE_DIV_OP) || (aluop_i == `EXE_DIVU_OP)) begin //乘法
        whilo_o <= `WriteEnable;
        hi_o <= divres1;  //高32位放在hi
        lo_o <= divres2;   //低32位放在lo
    end else if(aluop_i == `EXE_MTHI_OP) begin //对hi的移动操作
        whilo_o <= `WriteEnable;
        hi_o <= reg1_i;
        lo_o <= LO;
    end else if(aluop_i == `EXE_MTLO_OP) begin  //对lo的移动操作
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