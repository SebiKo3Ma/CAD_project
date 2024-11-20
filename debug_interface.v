`timescale 1ns/1ns
module debug_interface(input clk, rst, debug, frame_valid, send, data_out_valid, input[8:0] frame, frame_to_transmit, input[3:0] data_out, output[8:0] debug_frame, output [3:0] debug_reg);

reg[8:0] debug_frame_ff, debug_frame_nxt;
reg[3:0] debug_reg_ff, debug_reg_nxt;

assign debug_frame = debug_frame_ff;
assign debug_reg = debug_reg_ff;

    always @* begin
        debug_frame_nxt = debug_frame_ff;
        debug_reg_nxt = debug_reg_ff;

        if(frame_valid) begin
            debug_frame_nxt = frame;
        end
        // end else if(send) begin
        //     debug_frame_nxt = frame_to_transmit;
        // end

        if(data_out_valid) begin
            debug_reg_nxt = data_out;
        end

    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            debug_frame_ff <= 9'b000000000;
            debug_reg_ff <= 4'b0000;
        end else if(debug) begin
            debug_frame_ff <= debug_frame_nxt;
            debug_reg_ff <= debug_reg_nxt;
        end else begin
            debug_frame_ff <= 9'b000000000;
            debug_reg_ff <= 4'b0000;
        end
    end
endmodule