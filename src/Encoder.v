//****************************************
// 8 to 1 encoder
//****************************************

module Encoder(in, out);
  input[7:0] in;
  input[2:0] out;

  reg[2:0] out;

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
