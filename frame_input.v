`timescale 1ns/1ns
module frame_input(input clk, rst, send_ready, input[8:0] sw, output[8:0] frame_to_transmit, output send);
    reg[8:0] frame_ff, frame_nxt;
    reg send_check_ff, send_check_nxt, send_ff, send_nxt;

    assign send = send_ff;
    assign frame_to_transmit = frame_ff;    

    always @* begin
        frame_nxt[8] = sw[8];
        frame_nxt[7] = sw[7];
        frame_nxt[6] = sw[6];
        frame_nxt[5] = sw[5];
        frame_nxt[4] = sw[4];
        frame_nxt[3] = sw[3];
        frame_nxt[2] = sw[2];
        frame_nxt[1] = sw[1];
        frame_nxt[0] = sw[0];

        send_nxt = send_ff;
        send_check_nxt = send_check_ff;

        if(send_ready && !send_check_ff) begin
            send_nxt = 1'b1;
            send_check_nxt = 1'b1;
        end

        if(send_check_ff) begin
            send_nxt = 1'b0;
        end

        if(!send_ready && send_check_ff) begin
            send_check_nxt = 1'b0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            send_ff <= 1'b0;
            send_check_ff <= 1'b0;
            frame_ff <= 9'b000000000;
        end else begin
            send_ff <= send_nxt;
            send_check_ff <= send_check_nxt;
            frame_ff <= frame_nxt;
        end
    end
endmodule