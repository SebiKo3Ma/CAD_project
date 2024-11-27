`timescale 1ns/1ns
module clock_handler(input clk, rst, input[2:0] baud, output clk_16bd, clk_bd);
    reg [14:0] baud_ratio [4:0];
    wire [14:0] baudRatio16;
    
    assign baudRatio16 = baud_ratio[baud] >> 4;
    clk_divider #(27) clk_div_16bd(clk, rst, 1'b1, baudRatio16, clk_16bd);
    clk_divider #(27) clk_div_bd(clk, rst, 1'b1, baud_ratio[baud], clk_bd);
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            baud_ratio[0] <= 15'd64;
            baud_ratio[1] <= 15'd32; //10417 //32
            baud_ratio[2] <= 15'd48; //5208 //48
            baud_ratio[3] <= 15'd1736;
            baud_ratio[4] <= 15'd868;
        end
    end
endmodule