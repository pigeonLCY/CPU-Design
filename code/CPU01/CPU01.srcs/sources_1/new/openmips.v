//�������

`include "defines.v"

module openmips(

    clk,    //ʱ���ź�
    rst,    //��λ�ź�
    rom_data_i, //��ָ��洢��ȡ�õ�ָ��
    rom_addr_o, //�����ָ��洢���ĵ�ַ
    rom_ce_o,    //ָ��洢��ʹ��
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

input wire  clk;    //ʱ���ź�
input wire  rst;    //��λ�ź�
input wire[`RegBus]     rom_data_i; //��ָ��洢��ȡ�õ�ָ��
output wire[`RegBus]    rom_addr_o; //�����ָ��洢���ĵ�ַ
output wire             rom_ce_o;   //ָ��洢��ʹ��
//led
wire 	 led0_i;   //led0
wire    led1_i;   //led1
wire    led2_i;   //led2
wire    led3_i;   //led3
wire 	 led4_i;   //led0
wire    led5_i;   //led1
wire    led6_i;   //led2
wire    led7_i;   //led3
output wire 	led0_o;   //led0
output wire    led1_o;   //led1
output wire    led2_o;   //led2
output wire    led3_o;   //led3
output wire     led4_o;   //led0
output wire    led5_o;   //led1
output wire    led6_o;   //led2
output wire    led7_o;   //led3
//----------------------------------------------------------
//�������ģ��֮�����
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstBus] id_inst_i;
//led-wire


//IDģ�� -> D/EXģ��
wire[`AluOpBus] id_aluop_o;
wire[`AluSelBus] id_alusel_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire id_wreg_o;
wire[`RegAddrBus] id_wd_o;

//ID/EXģ�� -> EXģ��
wire[`AluOpBus] ex_aluop_i;
wire[`AluSelBus] ex_alusel_i;
wire[`RegBus] ex_reg1_i;
wire[`RegBus] ex_reg2_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;

//EXģ�� -> EX/MEMģ��
wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegBus] ex_wdata_o;
wire[`RegBus] ex_hi_o;
wire[`RegBus] ex_lo_o;
wire ex_whilo_o;

//EX/MEMģ�� -> MEMģ��
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegBus] mem_wdata_i;
wire[`RegBus] mem_hi_i;
wire[`RegBus] mem_lo_i;
wire mem_whilo_i;		

//MEMģ�� -> MEM/WBģ��
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegBus] mem_wdata_o;
wire[`RegBus] mem_hi_o;
wire[`RegBus] mem_lo_o;
wire mem_whilo_o;		

//MEM/WB -> wb	
wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegBus] wb_wdata_i;
wire[`RegBus] wb_hi_i;
wire[`RegBus] wb_lo_i;
wire wb_whilo_i;	

//IDģ�� <-> Regfile
wire reg1_read;
wire reg2_read;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

//exģ�� <-> hiloģ��
wire[`RegBus] 	hi;
wire[`RegBus]   lo;
//----------------------------------------------------------
//----------------------------------------------------------
//�����е�ģ�����ʵ����
//ע��˿ڵĶ�Ӧ
//pc_reg����
pc_reg pc_reg0(
    .clk(clk),      //ʱ���ź�
    .rst(rst),      //��λ
    .pc(pc),        //pc
    .ce(rom_ce_o)   //ָ��洢��ʹ��	
        
);
assign rom_addr_o = pc; //��pc��ֵ����ָ��洢��
//IF/IDģ������
if_id if_id0(
    .clk(clk),      //ʱ���ź�
    .rst(rst),      //��λ
    .if_pc(pc),     //��pc����
    .if_inst(rom_data_i),   //��ָ��洢������
    .id_pc(id_pc_i),
    .id_inst(id_inst_i)      	
);

//����׶�IDģ��
id id0(
    .rst(rst),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),

    .reg1_data_i(reg1_data),
    .reg2_data_i(reg2_data),

    //����ִ�н׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
    .ex_wreg_i(ex_wreg_o),
    .ex_wdata_i(ex_wdata_o),
    .ex_wd_i(ex_wd_o),

    //���ڷô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
    .mem_wreg_i(mem_wreg_o),
    .mem_wdata_i(mem_wdata_o),
    .mem_wd_i(mem_wd_o),

    //�͵�regfile����Ϣ
    .reg1_read_o(reg1_read),
    .reg2_read_o(reg2_read), 	  

    .reg1_addr_o(reg1_addr),
    .reg2_addr_o(reg2_addr), 
    
    //�͵�ID/EXģ�����Ϣ
    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o),
    .reg2_o(id_reg2_o),
    .wd_o(id_wd_o),
    .wreg_o(id_wreg_o)
);

//ͨ�üĴ���Regfile����
regfile regfile1(
    .clk (clk),
    .rst (rst),
    .we	(wb_wreg_i),
    .waddr (wb_wd_i),
    .wdata (wb_wdata_i),
    .re1 (reg1_read),
    .raddr1 (reg1_addr),
    .rdata1 (reg1_data),
    .re2 (reg2_read),
    .raddr2 (reg2_addr),
    .rdata2 (reg2_data),
    .led0_o(led0_i),  //led0
	.led1_o(led1_i),  //led1
	.led2_o(led2_i),  //led2
	.led3_o(led3_i),   //led3
	.led4_o(led4_i),  //led0
    .led5_o(led5_i),  //led1
    .led6_o(led6_i),  //led2
    .led7_o(led7_i)   //led3
);

//ID/EXģ��
id_ex id_ex0(
    .clk(clk),
    .rst(rst),
    
    //������׶�IDģ�鴫�ݵ���Ϣ
    .id_aluop(id_aluop_o),
    .id_alusel(id_alusel_o),
    .id_reg1(id_reg1_o),
    .id_reg2(id_reg2_o),
    .id_wd(id_wd_o),
    .id_wreg(id_wreg_o),

    //���ݵ�ִ�н׶�EXģ�����Ϣ
    .ex_aluop(ex_aluop_i),
    .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),
    .ex_wreg(ex_wreg_i)
);		

//EXģ��
ex ex0(
    .rst(rst),

    //�͵�ִ�н׶�EXģ�����Ϣ
    .aluop_i(ex_aluop_i),
    .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),
    .hi_i(hi),
    .lo_i(lo),

    .wb_hi_i(wb_hi_i),
    .wb_lo_i(wb_lo_i),
    .wb_whilo_i(wb_whilo_i),
    .mem_hi_i(mem_hi_o),
    .mem_lo_i(mem_lo_o),
    .mem_whilo_i(mem_whilo_o),
            
    //EXģ��������EX/MEMģ����Ϣ
    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o),

    .hi_o(ex_hi_o),
    .lo_o(ex_lo_o),
    .whilo_o(ex_whilo_o)
    
);

//EX/MEMģ��
ex_mem ex_mem0(
    .clk(clk),
    .rst(rst),
    
    //����ִ�н׶�EXģ�����Ϣ	
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),
    .ex_hi(ex_hi_o),
    .ex_lo(ex_lo_o),
    .ex_whilo(ex_whilo_o),		

    //�͵��ô�׶�MEMģ�����Ϣ
    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i),
    .mem_hi(mem_hi_i),
    .mem_lo(mem_lo_i),
    .mem_whilo(mem_whilo_i)		

                            
);

//MEMģ������
mem mem0(
    .rst(rst),

    //����EX/MEMģ�����Ϣ	
    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),
    .hi_i(mem_hi_i),
    .lo_i(mem_lo_i),
    .whilo_i(mem_whilo_i),		
    
    //�͵�MEM/WBģ�����Ϣ
    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o),
    .hi_o(mem_hi_o),
    .lo_o(mem_lo_o),
    .whilo_o(mem_whilo_o)		
);

//MEM/WBģ��
mem_wb mem_wb0(
    .clk(clk),
    .rst(rst),
    //���Էô�׶�MEMģ�����Ϣ	
    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),
    .mem_hi(mem_hi_o),
    .mem_lo(mem_lo_o),
    .mem_whilo(mem_whilo_o),		

    //�͵���д�׶ε���Ϣ
    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i),
    .wb_hi(wb_hi_i),
    .wb_lo(wb_lo_i),
    .wb_whilo(wb_whilo_i)		
                                        
);

hilo_reg hilo_reg0(
    .clk(clk),
    .rst(rst),

    //д�˿�
    .we(wb_whilo_i),
    .hi_i(wb_hi_i),
    .lo_i(wb_lo_i),

    //���˿�1
    .hi_o(hi),
    .lo_o(lo)	
);
//----------------------------------------------------------
//led
assign led0_o = led0_i;
assign led1_o = led1_i;
assign led2_o = led2_i;
assign led3_o = led3_i;
assign led4_o = led4_i;
assign led5_o = led5_i;
assign led6_o = led6_i;
assign led7_o = led7_i;
//----------------------------------------------------------
endmodule