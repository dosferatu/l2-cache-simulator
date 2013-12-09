//**************************************************
// Parameterized Multiplexor
//
// Defaults as an 8 to 1 multiplexor, but can be
// anything.
// 
// Inputs: The select bits are determined by the
// ceiling of the base 2 log function of the value
// of the "ways" parameter. The width of the input
// bus to the multiplexor is determined by the
// "ways" parameter.
//
// 3 select bits, 8 data inputs
// Outputs: out
//**************************************************

//module Multiplexor( select, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, out);
module Multiplexor( select, in0, in1, in2, in3, in4, in5, in6, in7, out);
parameter lineSize = 512;
parameter ways = 8;

input[$clog2(ways) - 1:0] select;
//input[lineSize - 1:0] in0, in1, in2, in3, in4, in5, in6, in7,in8, in9, in10, in11, in12, in13, in14, in15;
input[lineSize - 1:0] in0, in1, in2, in3, in4, in5, in6, in7;
output[lineSize - 1:0] out;

//wire [16 * lineSize - 1:0] in;
wire [8 * lineSize - 1:0] in;

//assign in = {in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15};
assign in = {in0, in1, in2, in3, in4, in5, in6, in7};
assign out = in[select];
endmodule
