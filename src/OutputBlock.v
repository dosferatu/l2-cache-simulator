//**************************************************
// OUTPUT BLOCK
// Inputs: (Cache data, Cache tag, Address tag, Valid bit) all according to
// cache index
// Outputs: Hit, Cache line
//**************************************************

`include "Comparator.v"
`include "Encoder.v"
`include "Multiplexor.v"

module HitDetector(
  valid,
  addressTag,
  cacheTag,
  cacheData,
  hit,
  cacheLine
); 

parameter indexBits = 14;
parameter lineSize = 512; // 64 byte line size
parameter tagBits = 12;
parameter ways = 8;

input[ways - 1:0] valid;
input[tagBits - 1:0] addressTag;

// Since the size of each element is defined we can use a single
// bus to define all the signals, and just separate according to
// defined widths per channel.
input[tagBits * ways - 1:0] cacheTag;
input[lineSize * ways - 1:0] cacheData;

output hit;
output[lineSize - 1:0] cacheLine;

wire[ways - 1:0] COMPARATOR_OUT;

// This is what I think I want to do, but it does not work
//wire encoder_out[$clog2(ways) - 1:0];
wire ENCODER_OUT; // This I believe is wrong, so it's temporary to compile
wire MUX_OUT;

// Generate parameter "ways" amount of comparators
genvar i;
generate
for (i = 0; i < ways; i = i + 1)
begin
  //This works, but it does not select a particular way, so I need to fix
  Comparator #(ways) comparator(.addressTag(addressTag), .cacheTag(cacheTag[i * tagBits + tagBits - 1:i * tagBits]), .match(COMPARATOR_OUT[i]));
end
endgenerate

// Instantiate our encoder for n ways
Encoder #(ways) encoder(comparator_out, encoder_out);

// I don't think this is quite right, but it's a stub for now
Multiplexor #(lineSize, ways)  multiplexor(.select(ENCODER_OUT), .in(cacheData[cacheData]), .out(MUX_OUT));

// Code such that all (tagBits - 1) comparator outputs and valid
// bits are ANDed together, and each output/valid pair are logically
// ORed for hit detection

// Output hit and the cache data
// Verify this works in the test bench otherwise see above
assign hit = comparator_out & valid;
assign cacheLine = MUX_OUT;
endmodule
