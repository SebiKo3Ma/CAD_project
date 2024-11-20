`timescale 1ns/1ns
module clock_module(input clk, rst, input[3:0] address, data, input valid, output ack, output[3:0] data_out, output data_out_valid, clk_16bd, clk_bd);
    wire[2:0] baud;
    clock_handler clock_handler(clk, rst, baud, clk_16bd, clk_bd);
    clock_regfile clock_regfile(clk, rst, address, data, valid, ack, data_out, data_out_valid, baud);
endmodule