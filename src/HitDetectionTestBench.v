//**************************************************
// Hit detection test bench
//**************************************************

module HitDetectorTestBench();

parameter ways = 8;
parameter indexBits = 14;
parameter lineSize = 512; // 64 byte line size
parameter tagBits = 10;

wire valid;
wire addressTag;
wire cacheTag;
wire cacheData;

reg hit;
reg cacheLine;

initial
begin
  // Apply stimulus to the hit detector to verify it's output
  // We will use a couple of arbitrary address and cache tags just to verify
  // that the datastructures and the logic are correctly detecting a hit/miss
  // and the cache datalines are properly being routed out from the mux
end
endmodule
