//**************************************************
// Comparator
//
// Inputs: Both the address and the cache tag which
// are the width of the "tagBits" parameter.
//
// Output: The output is the result of the logical
// comparison of both inputs.
//**************************************************

module Comparator(addressTag, cacheTag, match);
parameter tagBits = 12;

input[tagBits - 1:0] addressTag;
input[tagBits - 1:0] cacheTag;
output reg match;

// Run a comparison and output the result
always @(addressTag, cacheTag) begin

  if (addressTag == cacheTag) begin
    match = 1;
  end
  
  else begin
    match = 0;
  end
end
endmodule
