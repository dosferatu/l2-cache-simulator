//**************************************************
// Test bench for the L2 cache
//**************************************************

`include "L2Cache.v"

module L2CacheTestBench();

  // Configurable params for the architecture used
  parameter commandSize = 8;
  parameter addressSize = 32;
  
  //Configurable params for the cache implementation
  parameter ways        = 8;
  parameter sets        = 16384;
  parameter lineSize    = 512;
  reg [addressSize - 1:0] indexBits;
  reg [addressSize - 1:0] byteSelect;
  reg [addressSize - 1:0] tagBits;

  initial begin
    indexBits           = $clog2(sets);
    byteSelect          = $clog2(lineSize);
    tagBits             = indexBits - byteSelect bits;
  end

  // Wires to connect the cache and other modules to check operation of cache model
  wire [lineSize - 1:0]   sharedBus;
  wire [255:0]            L1Bus
  wire [7:0]              operationBus;
  wire [1:0]              snoopBus;

  // Instantiate our L2 cache
  L2Cache #(ways, indexBits, lineSize, tagBits) cache(.command(command), .L1Bus(L1Bus), .snoopBus(snoopBus), .sharedBus(sharedBus), .operationBus(operationBus));

  // Instantiate GetSnoopResult
  GetSnoopResult #(addressSize) snoop(.sharedBus(sharedAddress), .operation
  
  // Instantiate fileIO module
  FileIO #(addressSize) IO(.L1Bus(L1Bus), .sharedBus(sharedBus), .operationBus(operationBus));
  
endmodule

