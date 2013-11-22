// 8 to 1 multiplexor
// Inputs: 3 select bits, 8 64-byte wide data inputs
// Outputs: 64-byte wide multiplexor output

module Multiplexor (
  select,
  in0,
  in1,
  in2,
  in3,
  in4,
  in5,
  in6,
  in7,
  out
);
  input [2:0] select;
  input [511:0]in1;
  input [511:0]in2;
  input [511:0]in3;
  input [511:0]in4;
  input [511:0]in5;
  input [511:0]in6;
  input [511:0]in7;
  output out;
  reg out;

  always @(select or in)
  begin
    case (select)
      3'b000 : out = in0;
      3'b001 : out = in1;
      3'b010 : out = in2;
      3'b011 : out = in3;
      3'b100 : out = in4;
      3'b101 : out = in5;
      3'b110 : out = in6;
      3'b111 : out = in7;
    endcase

    // Output the state of the multiplexor
    $display("Cache multiplexor state:");
  end
endmodule
