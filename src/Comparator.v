//**************************************************
// Cache tag comparator:
// inputs: address tag, cache tag
// outputs: match
//**************************************************

module Comparator(addressTag, cacheTag, match);
parameter tagBits = 10;

input[tagBits - 1:0] addressTag;          // Tag coming from virtual address
input[tagBits - 1:0] cacheTag;            // Tag coming from cache location
output match;                             // Outputs if they match or not

assign match = addressTag & cacheTag;
endmodule
