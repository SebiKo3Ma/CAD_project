`timescale 1ns/1ns
module UART_receiver(input clk_16bd, rst, Rx, parity, parity_type, stop_bits, input[3:0] frame_length, output [8:0] frame, output frame_valid);
    localparam[2:0] IDLE = 3'b000,
                    START = 3'b001,
                    READ = 3'b010,
                    PARITY = 3'b011,
                    STOP = 3'b100,
                    DROP = 3'b101;

    reg[2:0] state_ff, state_nxt;
    reg crt_bit;
    reg odd_bits;

    reg[3:0] data_count_ff, data_count_nxt;
    reg[3:0] sample_count_ff, sample_count_nxt;
    reg parity_invalid;
    reg stop_count_ff, stop_count_nxt;

    reg[8:0] frame_ff, frame_nxt;
    reg frame_valid_ff, frame_valid_nxt;

    assign frame = frame_ff;
    assign frame_valid = frame_valid_ff;

    always @* begin
        state_nxt = state_ff;
        data_count_nxt = data_count_ff;
        stop_count_nxt = stop_count_ff;
        frame_nxt = frame_ff;
        frame_valid_nxt = frame_valid_ff;

        sample_count_nxt = sample_count_ff + 1;

        if(sample_count_ff == 4'd7) begin
                crt_bit = Rx;
        end

        case(state_ff)
            IDLE: begin
                if(frame_valid_ff) begin
                    frame_valid_nxt = 1'b0;
                end
                
                if(!Rx) begin
                    state_nxt = START;
                    sample_count_nxt = 4'd0;
                end else begin
                    state_nxt = IDLE;
                end
            end

            START: begin
                data_count_nxt = 0;
                frame_nxt = 9'd0;
                frame_valid_nxt = 1'b0;
                stop_count_nxt = 1'b0;
                odd_bits = 1'b0;
                parity_invalid = 1'b0;
                if(sample_count_ff == 4'd15) begin
                    state_nxt = READ;
                end
            end

            READ: begin
                if(data_count_ff == frame_length - 1 && sample_count_ff == 4'd15) begin
                    state_nxt = PARITY;
                end

                if(crt_bit && sample_count_ff == 4'd15) begin
                    frame_nxt = frame_ff | (9'b1 << data_count_ff );
                end
                if(sample_count_ff == 4'd15) begin
                    data_count_nxt = data_count_ff + 1;
                end
            end

            PARITY: begin
                if(!parity) begin
                    state_nxt = STOP;
                end else begin
                    odd_bits = frame_ff[0] ^ frame_ff[1] ^ frame_ff[2] ^ frame_ff[3] ^ frame_ff[4] ^ frame_ff[5] ^ frame_ff[6] ^ frame_ff[7] ^ frame_ff[8];
                    if(sample_count_ff == 4'd15) begin
                        if(!parity_type && odd_bits == crt_bit) begin  //even parity
                            state_nxt = STOP;
                        end else if(parity_type && odd_bits != crt_bit) begin //odd parity
                            state_nxt = STOP;
                        end else begin
                            parity_invalid = 1'b1;
                            state_nxt = STOP;
                        end
                    end
                end
            end

            STOP: begin
                if(sample_count_ff == 4'd15) begin
                    if(parity_invalid) begin
                        parity_invalid = 1'b0;
                        state_nxt = DROP;
                    end else if(!stop_bits) begin
                        if(crt_bit) begin
                            state_nxt = IDLE;
                            frame_valid_nxt = 1'b1;
                        end else begin
                            state_nxt = DROP;
                        end
                    end else begin

                        stop_count_nxt = stop_count_ff + 1;

                        if(!crt_bit) begin
                            state_nxt = DROP;
                        end else if(stop_count_ff) begin
                            state_nxt = IDLE;
                            frame_valid_nxt = 1'b1;
                        end
                    end
                end
            end

            DROP: begin
                frame_nxt = 9'b0;
                frame_valid_nxt = 1'b0;
                state_nxt = IDLE;
            end

            default: begin
                state_nxt = IDLE;
            end
        endcase
    end

    always @(posedge clk_16bd or posedge rst) begin
        if(rst) begin
            state_ff <= IDLE;
            sample_count_ff <= 4'b0;
            stop_count_ff <= 1'b0;
            data_count_ff <= 4'b0;
            frame_ff <= 9'b0;
            frame_valid_ff <= 1'b0;
        end else begin
            sample_count_ff <= sample_count_nxt;
            frame_valid_ff <= frame_valid_nxt;
            frame_ff <= frame_nxt;
            data_count_ff <= data_count_nxt;
            stop_count_ff <= stop_count_nxt;
            state_ff <= state_nxt;
        end
    end
endmodule