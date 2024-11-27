`timescale 1ns/1ns
module tb_top();
    reg clk, rst, debug, send_ready, Rx;
    reg [8:0] sw;
    wire Tx, fault;
    wire[8:0] debug_frame;
    wire[3:0] debug_reg;
    reg idle;

    top top(clk, rst, debug, send_ready, Rx, sw, Tx, fault, debug_frame, debug_reg);

    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end

    task receive(input [7:0] data);
        begin
            idle = 1'b0;
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
            
            #320 idle = 1'b1;
        end
    endtask

    task receive_noparity(input [7:0] data);
        begin
            idle = 1'b0;
            Rx = 1'b0; //start bit;
            #320 Rx = data[0];
            #320 Rx = data[1];
            #320 Rx = data[2];
            #320 Rx = data[3];
            #320 Rx = data[4];
            #320 Rx = data[5];
            #320 Rx = data[6];
            #320 Rx = data[7];

            #320 Rx = 1'b1; //stop bit
            
            #400 idle = 1'b1;
        end
    endtask

    task receive_oddparity(input [7:0] data);
        begin
            idle = 1'b0;
            Rx = 1'b0; //start bit;
            #320 Rx = data[0];
            #320 Rx = data[1];
            #320 Rx = data[2];
            #320 Rx = data[3];
            #320 Rx = data[4];
            #320 Rx = data[5];
            #320 Rx = data[6];
            #320 Rx = data[7];

            #320 Rx = ~(data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7]); //parity bit
            #320 Rx = 1'b1; //stop bit
            
            #400 idle = 1'b1;
        end
    endtask

    task receive_2stop(input [7:0] data);
        begin
            idle = 1'b0;
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
            #320 Rx = 1'b1;
            
            #320 idle = 1'b1;
        end
    endtask

    task receive_4800(input [7:0] data);
        begin
            idle = 1'b0;
            Rx = 1'b0; //start bit;
            #640 Rx = data[0];
            #640 Rx = data[1];
            #640 Rx = data[2];
            #640 Rx = data[3];
            #640 Rx = data[4];
            #640 Rx = data[5];
            #640 Rx = data[6];
            #640 Rx = data[7];

            #640 Rx = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7]; //parity bit
            #640 Rx = 1'b1; //stop bit
            
            #400 idle = 1'b1;
        end
    endtask

    task receive_6bits(input [5:0] data);
        begin
            idle = 1'b0;
            Rx = 1'b0; //start bit;
            #320 Rx = data[0];
            #320 Rx = data[1];
            #320 Rx = data[2];
            #320 Rx = data[3];
            #320 Rx = data[4];
            #320 Rx = data[5];

            #320 Rx = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5]; //parity bit
            #320 Rx = 1'b1; //stop bit
            
            #400 idle = 1'b1;
        end
    endtask

    

    initial begin
        rst = 1'b1;
        debug = 1'b1;
        send_ready = 1'b0;
        Rx = 1'b1;
        sw = 9'b000000000;
        idle = 1'b1;
        #20 rst = 1'b0;
        
        // receive default frame
        #40 receive(8'b00111010);

        // send default frame
        #300
        sw[0] = 1'b0;
        sw[1] = 1'b1;
        sw[2] = 1'b0;
        sw[3] = 1'b1;
        sw[4] = 1'b1;
        sw[5] = 1'b0;
        sw[6] = 1'b1;
        sw[7] = 1'b0;

        #50 send_ready = 1'b1;
        #1000 send_ready = 1'b0;

        // change baud rate to 4800
        #300 receive(8'b00010000);

        // receive at 4800 and 9600
        #400 receive_4800(8'b00111010);
        #400 receive(8'b01111010);

        // send at 4800
        #50 send_ready = 1'b1;
        #1000 send_ready = 1'b0;

        //hard reset
        #4000 rst = 1'b1;
        #40 rst = 1'b0;

        //change frame lenght to 6
        #4000 receive(8'b11000110);

        //receive 6-bit frame and regular frame
        #400 receive_6bits(6'b111010);
        #400 receive(8'b10111110);

        //send 6-bit frame
        #50 send_ready = 1'b1;
        #1000 send_ready = 1'b0;

        //soft reset
         #4000 receive_6bits(6'b000000);

        //change parity to none
        #400 receive(8'b10010000);

        //receive regular and no-parity frame
        #400 receive_noparity(8'b00111010);
        #400 receive(8'b00111010);

        //send no parity frame
        #50 send_ready = 1'b1;
        #1000 send_ready = 1'b0;

        //hard reset
        #4000 rst = 1'b1;
        #40 rst = 1'b0;

        //change parity to odd
        #4000 receive(8'b10100001);

        //receive even and odd parity frame
        #400 receive(8'b00111010);
        #400 receive_oddparity(8'b00111010);

        //send odd parity frame
        #50 send_ready = 1'b1;
        #1000 send_ready = 1'b0;

        //hard reset
        #4000 rst = 1'b1;
        #40 rst = 1'b0;

        //change stop bits to 2
        #4000 receive(8'b10110001);

        //receive 1 and 2 stop bit frames
        #400 receive(8'b00111010);
        receive_2stop(8'b00111010);
        receive_2stop(8'b00111010);

        //send 2 bit frame
        #50 send_ready = 1'b1;
        #1000 send_ready = 1'b0;

        //hard 
        #4000 rst = 1'b1;
        #40 rst = 1'b0;

        //view register values
        //baud rate
        #4000 receive(8'b00011111);
        
        //parity
        #400 receive(8'b10011111);

        //parity type
        #400 receive(8'b10101111);

        //stop bits
        #400 receive(8'b10111111);

        //frame length
        #400 receive(8'b11001111);

        //invalid register
        #400 receive(8'b00101111);
    end
endmodule