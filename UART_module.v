`timescale 1ns/1ns
module UART_module(input clk_16bd, clk_bd, clk, rst, Rx, valid, send, input[3:0] data, address, input[8:0] frame_to_transmit, output Tx, ack, data_out_valid, frame_valid, output[8:0] frame, output[3:0] data_out);

    wire parity, parity_type, stop_bits;
    wire[3:0] frame_length;

    UART_receiver UART_Rx(clk_16bd, rst, Rx, parity, parity_type, stop_bits, frame_length, frame, frame_valid);
    UART_transmitter UART_tx(clk_bd, rst, send, parity, parity_type, stop_bits, frame_length, frame_to_transmit, Tx);
    uart_regfile uart_regfile(clk, rst, valid, data, address, ack, data_out_valid, parity, parity_type, stop_bits, frame_length, data_out);
endmodule