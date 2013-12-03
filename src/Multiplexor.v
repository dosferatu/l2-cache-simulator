//**************************************************
// 8 to 1 multiplexor
// Inputs: 3 select bits, 8 data inputs
// Outputs: out
//**************************************************

module Multiplexor( select, in, out);
parameter ways = 8;

input[2:0] select;
input[ways - 1:0] in;
output reg out;

wire[2:0] select;
wire[ways - 1:0] in;

always @(select or in)
begin
  assign out = in[select];
end

endmodule
