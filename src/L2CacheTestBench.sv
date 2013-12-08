//**************************************************
// Test bench for the L2 cache
//**************************************************

//`include "GetSnoopResult.sv"
//`include "FileIO.sv"
//`include "L2Cache.sv"

module L2CacheTestBench();
  // Setup param for use in turning statistics on and off
  parameter stats = 0;
  
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
  /*
  // Stuff for statistics
  wire hit, miss, read, write;
  integer HIT, MISS, READ, WRITE;
  initial begin
    HIT = 0; MISS = 0; READ = 0; WRITE = 0;
  end
  */

  // Instantiate our L2 cache
  //L2Cache #(.ways(ways), .indexBits(indexBits), .lineSize(lineSize), .tagBits(tagBits)) cache(.L1Bus(L1Bus), .snoopBus(snoopBus), .sharedBus(sharedBus), .L1OperationBus(L1OperationBus), .sharedOperationBus(sharedOperationBus), .hit(hit), .miss(miss), .read(read), .write(write));

  // Instantiate GetSnoopResult
  GetSnoopResult #(.lineSize(lineSize)) snoop(.sharedBus(sharedBus), .sharedOperationBus(sharedOperationBus), .snoopBus(snoopBus));
  
  // Instantiate fileIO module
  FileIO #(addressSize) IO(.L1Bus(L1Bus), .sharedBus(sharedBus), .L1OperationBus(L1OperationBus), .sharedOperationBus(sharedOperationBus));
  
  // Take statistics
  /*
  always @(hit,miss,read,write) begin
    if(hit)
      HIT = HIT + 1;
    else if(miss)
      MISS = MISS + 1;
    else if(read)
      READ = READ + 1;
    else
      WRITE = WRITE + 1;
  end
*/
  initial begin
    $display("L1Bus       L1OperationBus          SharedBus         sharedOperationBus        snoopBus");
    $monitor("%8h         %8h         %8h         %c          %h",L1Bus,L1OperationBus,sharedBus,sharedOperationBus,snoopBus);
  end
  /*
  initial begin
    if(stats == 1) begin
      $display("HIT     MISS      READ      WRITE       RATIO");
      $monitor("%d      %d        %d        %d        %d", HIT, MISS, READ, WRITE, HIT/MISS);
    end
  end*/
endmodule

