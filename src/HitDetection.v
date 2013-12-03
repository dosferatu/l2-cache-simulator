//**************************************************
// HIT DETECTION
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

parameter ways = 8;
parameter tagBits = 10;
parameter dataBits = 9; // 64 bytes implies 9 bits needed

input[ways - 1:0] valid;
input[tagBits - 1:0] addressTag;
input[tagBits - 1:0] cacheTag;
input[(dataBits - 1) * ways:0] cacheData;
output reg hit;
output reg[dataBits - 1:0] cacheLine;

wire comparator_out[tagBits - 1:0];
wire encoder_out[$clog2(ways) - 1:0];
wire mux_out;

// Generate parameter "ways" amount of comparators

// Instantiate our encoder

// Generate 2^(parameter "dataBits") amount of multiplexors

// Code such that all (tagBits - 1) comparator outputs and valid
// bits are ANDed together, and each output/valid pair are logically
// ORed for hit detection

//This is wrong
//assign hit = comparator_out & valid

//assign cacheLine = mux_out;
endmodule
