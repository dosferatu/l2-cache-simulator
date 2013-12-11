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

module Multiplexor( select, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, out);
  // Establish parameters for configurability
  parameter     ways = 8;
  parameter lineSize = 512;

  // Define inputs and outputs
  input [$clog2(ways) - 1:0]  select;
  input [lineSize - 1:0]      in0, in1, in2, in3, in4, in5, in6, in7,in8, in9, in10, in11, in12, in13, in14, in15;
  output[lineSize - 1:0]      out;

  wire  [16 * lineSize - 1:0] in;

  // concatenate the inputs into one bus
  assign in = {in15,in14,in13,in12,in11,in10,in9,in8,in7,in6,in5,in4,in3,in2,in1,in0};
  
  // output sected way
  assign out = in[select];
endmodule
