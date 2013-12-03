//**************************************************
// Parameterized Cache tag comparator
//
// Inputs: Both the address and the cache tag which
// are the width of the "tagBits" parameter.
//
// Output: The output is the AND function of both
// inputs.
//**************************************************

module Comparator(addressTag, cacheTag, match);
parameter tagBits = 10;

input[tagBits - 1:0] addressTag;          // Tag coming from virtual address
input[tagBits - 1:0] cacheTag;            // Tag coming from cache location
output match;                             // Outputs if they match or not

assign match = addressTag & cacheTag;
endmodule
