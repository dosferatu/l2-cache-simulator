//**************************************************
// Test bench for the L2 cache
//**************************************************

module L2CacheTestBench();
  // Setup param for use in turning statistics on and off
  parameter stats = 0;
  parameter display = 0;
  
  // Configurable params for the architecture used
  parameter commandSize = 8;
  parameter addressSize = 32;
  
  // Configurable params for the cache implementation
  parameter ways        = 8;
  parameter sets        = 16384;
  parameter lineSize    = 512;
  parameter indexBits   = 14;
  parameter byteSelect  = 6;
  parameter tagBits   = addressSize - indexBits - byteSelect;

  // Wires to connect the cache and other modules to check operation of cache model
  wire [lineSize - 1:0]   sharedBus;
  wire [255:0]            L1Bus;
  wire [15:0]             L1OperationBus;
  wire [7:0]              sharedOperationBus;
  wire [1:0]              snoopBus;
  
  // Stuff for statistics
  wire [31:0] hit;
  wire [31:0] miss;
  wire [31:0] read;
  wire [31:0] write;
  integer HIT, MISS, READ, WRITE;
  initial begin
    HIT = 0; MISS = 0; READ = 0; WRITE = 0;
  end
 

  // Instantiate our L2 cache
  L2Cache #(.display(display), .ways(ways), .indexBits(indexBits), .lineSize(lineSize), .tagBits(tagBits)) cache(.L1Bus(L1Bus), .snoopBus(snoopBus), .sharedBus(sharedBus), .L1OperationBus(L1OperationBus), .sharedOperationBus(sharedOperationBus), .hit(hit), .miss(miss), .read(read), .write(write));

  // Instantiate GetSnoopResult
  GetSnoopResult #(.lineSize(lineSize)) snoop(.sharedBus(sharedBus), .sharedOperationBus(sharedOperationBus), .snoopBus(snoopBus));

  // Instantiate fileIO module
  FileIO #(.display(display), .addressSize(addressSize)) IO(.L1Bus(L1Bus), .sharedBus(sharedBus), .L1OperationBus(L1OperationBus), .sharedOperationBus(sharedOperationBus));
  
  always @(L1OperationBus) begin
    if (L1OperationBus == "PS") begin
      $display("Hits: %d \t Misses: %d \t Reads: %d \t Writes: %d \t Hit/Miss ratio: %d / %d", hit, miss, read, write, hit, miss);
    end
  end
endmodule
