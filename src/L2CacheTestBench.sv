//**************************************************
// Test bench for the L2 cache
//**************************************************

module L2CacheTestBench();
  // Setup param for use in turning statistics on and off
  parameter stats       = 0;
  parameter display     = 0;
  
  // Configurable params for the architecture used
  parameter commandSize = 8;
  parameter addressSize = 32;
  
  // Configurable params for the cache implementation
  parameter ways        = 8;
  parameter sets        = 16384;
  parameter lineSize    = 512;
  parameter indexBits   = 14;
  parameter byteSelect  = 6;
  parameter tagBits     = addressSize - indexBits - byteSelect;

  // Wires to connect the cache and other modules to check operation of cache model
  wire [lineSize - 1:0]   sharedBusIn;
  wire [lineSize - 1:0]   sharedBusOut;
  wire [255:0]            L1BusIn;
  wire [255:0]            L1BusOut;
  wire [15:0]             L1OperationBusIn;
  wire [7:0]              sharedOperationBusIn;
  wire [7:0]              sharedOperationBusOut;
  wire [1:0]              snoopBusIn;
  wire [1:0]              snoopBusOut;
  
  // Stuff for statistics
  wire [31:0] hit;
  wire [31:0] miss;
  wire [31:0] read;
  wire [31:0] write;

  // Instantiate our L2 cache
  L2Cache #(.display(display), .ways(ways), .indexBits(indexBits), .lineSize(lineSize), .tagBits(tagBits)) cache(.L1BusIn(L1BusIn), .L1BusOut(L1BusOut), .L1OperationBusIn(L1OperationBusIn), .snoopBus(snoopBus), .sharedBusIn(sharedBusIn), .sharedBusOut(sharedBusOut), .sharedOperationBusIn(sharedOperationBusIn), .sharedOperationBusOut(sharedOperationBusOut), .hit(hit), .miss(miss), .read(read), .write(write));

  // Instantiate GetSnoopResult
  GetSnoopResult #(.lineSize(lineSize)) snoop(.sharedBusOut(sharedBusOut), .sharedOperationBusOut(sharedOperationBusOut), .snoopBusIn(snoopBusIn));

  // Instantiate fileIO module
  FileIO #(.display(display), .addressSize(addressSize)) IO(.L1BusIn(L1BusIn), .sharedBusIn(sharedBusIn), .L1OperationBusIn(L1OperationBusIn), .sharedOperationBusIn(sharedOperationBusIn));
  
  always @(L1OperationBus) begin
    if (L1OperationBus == "PS")
      $display("Hits: %d \t Misses: %d \t Reads: %d \t Writes: %d \t Hit/Miss ratio: %d / %d", hit, miss, read, write, hit, miss);
  end
endmodule
