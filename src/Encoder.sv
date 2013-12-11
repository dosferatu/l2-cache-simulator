//**************************************************
// Parameterized encoder
//
// Defaults as 8 to 3 encoder, but can be anything.
//
// Input: The width of the input is the value of
// the "ways" parameter.
//
// Output: The select bits are determined by the
// ceiling of the base 2 log function of the value
// of the "ways" parameter.
//**************************************************

module Encoder(in, out);
  parameter ways = 8;

  input[ways - 1:0] in;

  // Take the base 2 log of the encoder input parameter
  output reg [$clog2(ways) - 1:0] out;

  // Give output according to log base 2 of the input
  always @(in) begin
  if(in == 0)
    out = 8'bx;
  else
    out = $clog2(in);
  end
endmodule
