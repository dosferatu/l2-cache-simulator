//**************************************************
// CACHE DATA STRUCTURE BLOCK
//**************************************************

module DataStructureBlock(index, addressTag, cacheTag, cacheData, read);
  // Establish parameters to be used to dynamically change cache size/structure
  parameter indexBits = 14;
  parameter lineSize = 512;
  parameter tagBits = 12;
  parameter ways = 8;

  // Declare inputs/outputs of the data structure block as dynamic elements
  input index[indexBits - 1:0];
  input addressTag[tagBits - 1:0];
  input read;

  output cacheData[lineSize -1:0];
  output cacheTag[tagBits - 1:0];

  // Establish necessary reg/nets for use within the data structure for passing 
  /*reg[lineSize - 1:0] cacheData;
  reg[tagBits - 1:0] cacheTag;
  reg[$clog2(ways) - 1:0] selectedWay;
  wire[$clog2(ways) - 1:0] SELECTED_WAY;*/
  // Changed to a struct to be used to create a line for each way in the set associative cache
  typedef struct {
    bit[tagBits - 1:0] cacheTag;
    bit[lineSize - 1:0] cacheData;
    bit[3:0] mesi;
    bit[$clog2(ways) - 1:0] lru;
  } set;

  // Generate n ways using n structs x m sets
  set Storage[$clog2(ways) - 1:0][indexBits - 1:0];

  // Performs necessary tasks/functions depending on whether there is a read or right to the cache
  always@(*)
  begin
    if (read) begin
      // read cache
      //ReadCache(Storage,index,;
      // update LRU
    end
    else begin
      // read for ownership on shared bus
      // query LRU for way to select
      //QueryLRU(index, SELECTED_WAY);
      // write cache
      // update LRU
    end
  end
endmodule
