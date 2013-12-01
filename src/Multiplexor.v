//**************************************************
// 8 to 1 multiplexor
// Inputs: 3 select bits, 8 data inputs
// Outputs: out
//**************************************************

module Multiplexor( select, in, out);
  input[2:0] select;
  input[7:0] in;
  output     out;

  reg       out;
  wire[2:0] select;
  wire[7:0] in;

  always @(select or in)
  begin
    assign out = in[select];
  end

endmodule
