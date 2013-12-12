module addressDissector (addressIn, address,addressTag,byteSelect,index);
  // Establish parameters for configurability
  parameter addressSize     = 32;
  parameter byteSelectBits  = 6;
  parameter indexBits       = 14;
  parameter lineSize        = 9 * 1024;
  parameter tagBits         = 12;
  
  // Define inputs and outputs
  input       [lineSize - 1:0]      addressIn;
  output reg  [addressSize - 1:0]   address;
  output reg  [tagBits - 1:0]       addressTag;
  output reg  [byteSelectBits- 1:0] byteSelect;
  output reg  [indexBits - 1:0]     index;

  //Initialize address parts
  initial begin
    address = 0;
    addressTag = 0;
  end

  always @(addressIn) begin
    // Disect address
    addressTag  <= addressIn[addressSize - 1:byteSelectBits + indexBits];
    byteSelect  <= addressIn[byteSelectBits - 1:0];
    index       <= addressIn[byteSelectBits + indexBits - 1:byteSelectBits];
    address     <= addressIn[addressSize - 1:0];
  end

endmodule
