`timescale 1ns / 1ps
`include "defines.v"
module delay_clk(
    clk_i,
    clk_o
    );
input  wire clk_i;
output reg clk_o;//�ӳ�ʱ��
reg[31:0] count;    //����һ��28λ�ļĴ�������¼����
initial clk_o = 0;
initial count = 32'b0;
always @ (posedge clk_i) begin
    //if(count >= 32'd30000) begin
    if(count > 32'd13500000) begin //1�� 1Hz
        count <=  32'd0;
        clk_o <= ~clk_o;
    end else begin
        count <= count + 1'd1;    
    end

end



endmodule
