//**************************************************
// L2 Cache module
//
//**************************************************

`include "DataStructureBlock.v"
`include "OutputBlock.v"

module L2Cache(command, L1Bus, snoopBus, sharedBus);
  // Establish parameters that can be used for dynamic sizing of cache
  parameter ways      = 8;    // Number of ways for set associativity
  parameter indexBits = 14;   // Number of bits used for indexing to a set in way
  parameter tagBits   = 12;   //
  parameter lineSize  = 512;  // Size of the line of data in a set and used for shared bus size
  parameter L1BusSize = 256;  // Size of Bus to communicate with the L1

  // Declare inputs and outputs
  input   [7:0]                       command;  // This will bring in the command operation from the trace file
  inout   [L1BusSize - 1:0]           L1Bus;    // Bus used for communicating with L1
  inout   [2:0]                       snoopBus; // Bus for getting/putting snoops
  inout   [lineSize - 1:0]            sharedBus;// FSB used by other processors and DRAM

  reg data[lineSize - 1:0];
  reg read;

  wire[tagBits - 1:0] CACHE_TAG;
  wire[lineSize - 1:0] CACHE_DATA;
  wire[lineSize - 1:0] SELECTED_CACHE_DATA;
  wire HIT;
  wire[3:0] MESI;

  /*
  * The data structure block and output block need to be heavily scrutinized to
  * verity that the proper inputs and outputs are present for any requirements
  * our cache implementation will need including cache coherency protocol.
  * Please change as desired or make note of any needed changes.
  */
  
  // Instantiate the cache storage block
  DataStructureBlock #(indexBits, lineSize, tagBits, ways) Cache(address[indexBits - 1:0], address[tagBits - 1:indexBits], CACHE_TAG, CACHE_DATA, read);

  /*
  * TIE ALL CACHE DATA OUTPUTS IN TO ONE WIDE CHANNEL TO SEND TO OUTPUT BLOCK
  */
  // Instantiate the cache output block and wire it to the storage block
  OutputBlock #(indexBits, lineSize, tagBits, ways) CacheOutput(MESI[0], addressTag, CACHE_TAG, HIT, SELECTED_CACHE_DATA);
endmodule
