`timescale 1ns/1ns
module top(input clk, rst, debug, send_ready, Rx, input[8:0] sw, output Tx, fault, output[8:0] debug_frame, output[3:0] debug_reg);
    wire clk_16bd, clk_bd, valid, ack, ack_clk, ack_uart, data_out_valid, frame_valid, send;
    wire[3:0] address, data, data_out;
    wire[8:0] frame, frame_to_transmit;

    assign ack = ack_uart | ack_clk;

    UART_module UART(clk_16bd, clk_bd, clk, rst, Rx, valid, send, data, address, frame_to_transmit, Tx, ack_uart, 
        data_out_valid, frame_valid, frame, data_out);

    config_module config_module(clk, rst, frame, frame_valid, ack, data, address, valid, fault);

    clock_module clk_module(clk, rst, address, data, valid, ack_clk, data_out, 
        data_out_valid, clk_16bd, clk_bd);

    debug_interface dbg(clk, rst, debug, frame_valid, send, data_out_valid,
        frame, frame_to_transmit, data_out, debug_frame, debug_reg);
    
    frame_input frame_input(clk, rst, send_ready, sw, frame_to_transmit, send);
endmodule