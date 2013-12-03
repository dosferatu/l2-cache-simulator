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
output reg[$clog2(ways) - 1:0] out;

always @(in)
begin
  case(in)
    16'h00:
      out = 3'b001;

    16'h01:
      out = 3'b001;

    16'h02:
      out = 3'b010;

    16'h03:
      out = 3'b011;

    16'h04:
      out = 3'b100;

    16'h05:
      out = 3'b101;

    16'h06:
      out = 3'b110;

    16'h07:
      out = 3'b111;
  endcase
end
endmodule
