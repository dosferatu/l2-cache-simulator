// HIT DETECTION
// Instantiate the 8 to 1 multiplexor using the cache data as the inputs,
// and wire up the select bits to an AND function of the comparator and the
// valid bit of each line.
//
// Hit detection will be the OR function of all the select bits, and if
// a hit is detected then the corresponding data will be output by the
// multiplexor.
//
// Long story short --
// Inputs: (Cache data, Cache tag, Address tag, Valid bit) all according to
// cache index
// Outputs: Hit, Cache line

module HitDetector(
  clock,
  valid,
  addressTag,
  cacheTag,
  cacheData,
  hit,
  cacheLine
);

input clock;
input [7:0] valid;
input [7:0] addressTag;
input [7:0] cacheTag;
input [7:0] cacheData;
output hit;
output cacheLine;

//Instantiate 8 to 1 mux here using cache data inputs and comparater select
//bit inputs.

endmodule
