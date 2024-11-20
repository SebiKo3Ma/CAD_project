module clock_regfile(input clk, rst, input[3:0] address, data, input valid, output ack, output[3:0] data_out, output data_out_valid, output[2:0] baud);
    
    reg ack_ff, ack_nxt, data_out_valid_ff, data_out_valid_nxt;
    reg[3:0] data_out_ff, data_out_nxt;
    reg[2:0] baud_ff, baud_nxt;
    reg count_ff, count_nxt;

    assign baud = baud_ff;
    assign ack = ack_ff;
    assign data_out = data_out_ff;
    assign data_out_valid = data_out_valid_ff;

    always @* begin
        baud_nxt = baud_ff;
        count_nxt = count_ff;
        ack_nxt = ack_ff;
        data_out_nxt = data_out_ff;
        data_out_valid_nxt = data_out_valid_ff;

        if(valid && !count_ff) begin
            case(address)
                4'b0000: begin
                    baud_nxt = 3'b001;
                end

                4'b0001: begin
                    if(data == 4'b1111) begin
                        data_out_nxt = baud_nxt;
                        data_out_valid_nxt = 1'b1;
                    end else begin
                        baud_nxt = data[2:0];
                    end
                    
                    ack_nxt = 1'b1;
                    count_nxt = 1'b1;
                end

                default: begin
                end
            endcase
        end

        if(count_ff) begin
            ack_nxt = 1'b0;
            count_nxt = 1'b0;
            data_out_valid_nxt = 1'b0;
            data_out_nxt = 4'b0000;
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            baud_ff <= 3'b001;
            count_ff <= 1'b0;
            ack_ff <= 1'b0;
            data_out_ff <= 4'b0000;
            data_out_valid_ff <= 1'b0;
        end else begin
            baud_ff <= baud_nxt;
            count_ff <= count_nxt;
            ack_ff <= ack_nxt;
            data_out_ff <= data_out_nxt;
            data_out_valid_ff <= data_out_valid_nxt;
        end
    end
endmodule