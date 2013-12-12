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
  // Establish parameters for configurability
  
  parameter tagBits = 12;

  // Define inputs and outputs of the module
  input[tagBits - 1:0] addressTag;
  input[tagBits - 1:0] cacheTag;
  output reg match;


  // Run a comparison and output the result
  always @(addressTag, cacheTag) begin
    

    $display("Address tag: %h, Cache tag: %h", addressTag, cacheTag);

    // If the addressTag and cacheTag are equal it is a match
    if (addressTag == cacheTag)
      match = 1;
    // If not a match
    else
      match = 0;
  end
endmodule
