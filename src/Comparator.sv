//**************************************************
//  Comparator
//
// Inputs: Both the address and the cache tag which
// are the width of the "tagBits" parameter.
//
// Output: The output is the result of the logical
// comparison of both inputs.
//**************************************************

module Comparator(address, addressTag, cacheTag, match);
  parameter display = 0;

  // Establish parameters for configurability
  parameter addressSize = 32;
  parameter tagBits = 12;

  // Define inputs and outputs of the module
  input[addressSize - 1:0] address;
  input[tagBits - 1:0] addressTag;
  input[tagBits - 1:0] cacheTag;
  output reg match;


  // Run a comparison and output the result
  always @(address) begin
    
    // If the addressTag and cacheTag are equal it is a match
    if (addressTag == cacheTag) begin
      match = 1;
    end

    // If not a match
    else begin
      match = 0;
    end
  
    if (display) begin
      $display("Comp --> Address Tag: %h \t Cache Tag: %h",addressTag,cacheTag);
    end
  end
endmodule
