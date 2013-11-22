module MultiplexorTestBench;
  reg [2:0] select;
  reg [511:0] in0;
  reg [511:0] in1;
  reg [511:0] in2;
  reg [511:0] in3;
  reg [511:0] in4;
  reg [511:0] in5;
  reg [511:0] in6;
  reg [511:0] in7;
  wire out;

  Multiplexor U0 (
    .select (select),
    .in0     (in0),
    .in1     (in1),
    .in2     (in2),
    .in3     (in3),
    .in4     (in4),
    .in5     (in5),
    .in6     (in6),
    .in7     (in7),
    .out    (out)
  );

  initial
  begin
    select = 3'b000;
    in0 = 0x1;

    select = 3'b001;
    in1 = 0x10;

    select = 3'b010;
    in2 = 0x100;

    select = 3'b011;
    in3 = 0x1000;

    select = 3'b100;
    in4 = 0x10000;

    select = 3'b101;
    in5 = 0x100000;

    select = 3'b110;
    in6 = 0x1000000;

    select = 3'b111;
    in7 = 0x10000000;
  end
endmodule
