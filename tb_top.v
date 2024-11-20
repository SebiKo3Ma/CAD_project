`timescale 1ns/1ns
module tb_top();
    reg clk, rst, debug, send_ready, Rx;
    reg [8:0] sw;
    wire Tx, fault;
    wire[8:0] debug_frame;
    wire[3:0] debug_reg;

    top top(clk, rst, debug, send_ready, Rx, sw, Tx, fault, debug_frame, debug_reg);

    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end

    task send(input [7:0] data);
        begin
            Rx = 1'b0; //start bit;
            #320 Rx = data[0];
            #320 Rx = data[1];
            #320 Rx = data[2];
            #320 Rx = data[3];
            #320 Rx = data[4];
            #320 Rx = data[5];
            #320 Rx = data[6];
            #320 Rx = data[7];

            #320 Rx = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7]; //parity bit
            #320 Rx = 1'b1; //stop bit
            
            #400;
        end
    endtask

    initial begin
        rst = 1'b1;
        debug = 1'b1;
        send_ready = 1'b0;
        Rx = 1'b1;
        sw = 9'b000000000;
        #20 rst = 1'b0;
        /*
        #40
        send(8'b10100001);
        
        #20 rst = 1'b1;
        #20 rst = 1'b0;

        #40
        send(8'b00010000);

        #50
        rst = 1'b1;
        #40 rst = 1'b0;
        */
        #300
        sw[0] = 1'b1;
        sw[1] = 1'b0;
        sw[2] = 1'b1;
        sw[3] = 1'b0;
        sw[4] = 1'b1;
        sw[5] = 1'b0;
        sw[6] = 1'b1;
        sw[7] = 1'b0;

        #50 send_ready = 1'b1;
        #1000 send_ready = 1'b0;
    end
endmodule