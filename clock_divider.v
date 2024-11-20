`timescale 1ns/1ns
module clk_divider#(parameter width = 4)
  			   (input clk, rst, en, input[14:0] ratio, output div_clk);
  
  // you can use parameter in order to declare inputs/outputs/internal signal width
  // you can also declare "localparam" this is a type of parameter that can`t be change from outside of the module
  // you can use "localparam" for internal process of parameter value => the simulator will treat them as constants after the compilation phase
  // for details check: https://www.chipverify.com/verilog/verilog-parameters  
  wire [width-2:0] HALD_COUNT;
  reg [width-1:0] count_ff,count_next;
  reg drive_ff, drive_next;
  
  assign div_clk = drive_ff;
  assign HALD_COUNT = (ratio-1)/2;
  
  // this always bloc will be synthesize as combinational logic
  always @* begin
    drive_next = drive_ff;
    count_next = count_ff;
    if(en) begin
      if(count_ff == (ratio-1)) begin
        drive_next = 1'b0;
        count_next = 'b0;
      end else begin
        count_next = count_ff+1'b1;
        if(count_ff < HALD_COUNT) begin
          drive_next = 1'b0;
        end else begin
          drive_next = 1'b1;
        end
      end
    end
  end
  
  // this always bloc will be synthesize as sequential logic
  always @(posedge clk or posedge rst) begin
    if(rst) begin
      drive_ff <= 1'b0;
      count_ff <= 'b0;  // if you don`t know the width use 'b0 and the compiler will insert 0 on all defined bits
    end else begin
      drive_ff <= drive_next;
      count_ff <= count_next;
    end
  end
endmodule 
