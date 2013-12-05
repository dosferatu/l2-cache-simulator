//**************************************************
// L2 Cache module
//
//**************************************************

`include "DataStructureBlock.v"
`include "OutputBlock.v"
`include "Tasks.v"

module L2Cache(command, address, L1Bus, snoopBus, sharedBus);
  // Establish parameters that can be used for dynamic sizing of cache
  parameter indexBits = 14;   // Number of bits used for indexing to a set in way
  parameter instructionSize = 32; // Width of processor instructions
  parameter lineSize  = 512;  // Size of the line of data in a set and used for shared bus size
  parameter tagBits   = 12;   //
  parameter ways      = 8;    // Number of ways for set associativity
  parameter L1BusSize = 256;  // Size of Bus to communicate with the L1

  // Declare inputs and outputs
  input   [7:0]                       command;  // This will bring in the command operation from the trace file
  input [instructionSize - 1:0]       address;

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

task QueryLRU (input index[indexBits - 1:0],
               output way[$clog2(ways) - 1:0]);
  begin
    // Loop through the set array at row[index]
    // Store LRU bits for each way
    //for (i=0,i<ways,++i)
    //for (j=0,j<$clog2(ways),++j)
    //LRUbits[j][i]=set[i][index].LRUbits[j][i];

    // Check to see which is the least recently used
    integer LRUvalue = 0;

    integer i, j;
    for (i = 0; i < ways; i = i + 1)
      for (j = 0; j < $clog2(ways); j = j  +1)
        LRUbits[j][i]=set[i][index].lru[j][i];

    //for (i=0,i<ways,++i)
    //if(LRUbits[i][$clog2(ways)-1:0]>LRUbits)
      //begin
      //LRU value= LRUbits[i][$clog2(ways)-1:0];
      //way= i;
      //end
      // Return way for which the LRU bits
      // designate as the oldest.
  end
endtask

task UpdateLRU  (input index[indexBits - 1:0], way[$clog2(ways) - 1:0]);
  begin
    // Array to store the LRU bits from each way
    reg LRUbits[$clog2(ways) - 1:0][$clog2(ways) - 1:0];

    // Loop through the set array at row[index]
    integer i, j;
    for (i = 0; i < ways; i = i + 1)
      for (j = 0; j < $clog2(ways); j = j  +1)
        LRUbits[j][i]=set[i][index].lru[j][i];
	
    // Store LRU bits for each way
    // Run LRU logic to update fields given
    // Initialise all the bits to '0' first
    // The accessed line is set to '0' (in later cases it is brought down to '0' but here its already 0 and remains same )
    //After that increment all the bits assigned to other lines by 1
    // In this case take one more condition like if the line already has a higher bit than any other bit , then it remains same
    // So, if it is already highest , keep it the same
    // If more than one line has same bit assigned to it, then evict the line that comes first from left
    // which way is being read/written to
  end
endtask

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
