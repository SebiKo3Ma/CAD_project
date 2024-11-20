`timescale 1ns/1ns
module UART_transmitter(input clk, rst, send, parity, parity_type, stop_bits, 
            input[3:0] frame_length, input[8:0] frame_to_transmit, output Tx);
    localparam[2:0] IDLE = 3'b000,
                    START = 3'b001,
                    SEND = 3'b010,
                    PARITY = 3'b011,
                    STOP = 3'b100;

    reg Tx_ff, Tx_nxt;
    reg[2:0] state_ff, state_nxt;
    reg[3:0] count_ff, count_nxt;
    reg check_ff, check_nxt;

    assign Tx = Tx_ff;

    always @* begin
        state_nxt = state_ff;
        Tx_nxt = Tx_ff;
        count_nxt = count_ff;
        check_nxt = check_ff;

        case(state_ff)
            IDLE: begin
                if(send) begin
                    state_nxt = START;
                end else begin 
                    Tx_nxt = 1'b1;
                end
            end

            START: begin
                Tx_nxt = 1'b0;
                state_nxt = SEND;
                count_nxt = 4'b0000;
            end

            SEND: begin
                Tx_nxt = frame_to_transmit[count_ff];
                count_nxt = count_ff + 1;

                if(count_ff == frame_length) begin
                    if(parity) begin
                        state_nxt = PARITY;
                    end else begin
                        state_nxt = STOP;
                    end
                end
            end

            PARITY: begin
                case(frame_length)
                    4'd5: begin
                        if(parity_type) begin
                            Tx_nxt = ~(frame_to_transmit[0] ^ frame_to_transmit[1] ^ frame_to_transmit[2] ^ frame_to_transmit[3] ^ frame_to_transmit[4]);
                        end else begin
                            Tx_nxt = frame_to_transmit[0] ^ frame_to_transmit[1] ^ frame_to_transmit[2] ^ frame_to_transmit[3] ^ frame_to_transmit[4];
                        end
                    end

                    4'd6: begin
                        if(parity_type) begin
                            Tx_nxt = ~(frame_to_transmit[0] ^ frame_to_transmit[1] ^ frame_to_transmit[2] ^ frame_to_transmit[3] ^ frame_to_transmit[4] ^ frame_to_transmit[5]);
                        end else begin
                            Tx_nxt = frame_to_transmit[0] ^ frame_to_transmit[1] ^ frame_to_transmit[2] ^ frame_to_transmit[3] ^ frame_to_transmit[4] ^ frame_to_transmit[5];
                        end
                    end

                    4'd7: begin
                        if(parity_type) begin
                            Tx_nxt = ~(frame_to_transmit[0] ^ frame_to_transmit[1] ^ frame_to_transmit[2] ^ frame_to_transmit[3] ^ frame_to_transmit[4] ^ frame_to_transmit[5] ^ frame_to_transmit[6]);
                        end else begin
                            Tx_nxt = frame_to_transmit[0] ^ frame_to_transmit[1] ^ frame_to_transmit[2] ^ frame_to_transmit[3] ^ frame_to_transmit[4] ^ frame_to_transmit[5] ^ frame_to_transmit[6];
                        end
                    end

                    4'd8: begin
                        if(parity_type) begin
                            Tx_nxt = ~(frame_to_transmit[0] ^ frame_to_transmit[1] ^ frame_to_transmit[2] ^ frame_to_transmit[3] ^ frame_to_transmit[4] ^ frame_to_transmit[5] ^ frame_to_transmit[6] ^ frame_to_transmit[7]);
                        end else begin
                            Tx_nxt = frame_to_transmit[0] ^ frame_to_transmit[1] ^ frame_to_transmit[2] ^ frame_to_transmit[3] ^ frame_to_transmit[4] ^ frame_to_transmit[5] ^ frame_to_transmit[6] ^ frame_to_transmit[7];
                        end
                    end

                    4'd9: begin
                        if(parity_type) begin
                            Tx_nxt = ~(frame_to_transmit[0] ^ frame_to_transmit[1] ^ frame_to_transmit[2] ^ frame_to_transmit[3] ^ frame_to_transmit[4] ^ frame_to_transmit[5] ^ frame_to_transmit[6] ^ frame_to_transmit[7] ^ frame_to_transmit[8]);
                        end else begin
                            Tx_nxt = frame_to_transmit[0] ^ frame_to_transmit[1] ^ frame_to_transmit[2] ^ frame_to_transmit[3] ^ frame_to_transmit[4] ^ frame_to_transmit[5] ^ frame_to_transmit[6] ^ frame_to_transmit[7] ^ frame_to_transmit[8];
                        end
                    end
                endcase
            end

            STOP: begin
                if(!stop_bits) begin
                    Tx_nxt = 1'b1;
                    state_nxt = IDLE;
                end else begin
                    if(!check_ff) begin
                        Tx_nxt = 1'b1;
                        check_nxt = 1'b1;
                    end else begin
                        Tx_nxt = 1'b1;
                        check_nxt = 1'b0;
                        state_nxt = IDLE;
                    end
                end
            end
        endcase
    end


    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state_ff <= IDLE;
            Tx_ff <= 1'b1;
            count_ff <= 4'b0000;
            check_ff <= 1'b0;
        end else begin
            Tx_ff <= Tx_nxt;
            count_ff <= count_nxt;
            check_ff <= check_nxt;
            state_ff <= state_nxt;
        end
    end
endmodule