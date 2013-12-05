//**************************************************
// CACHE DATA STRUCTURE BLOCK
//**************************************************


module DataStructureBlock(index, addressTag, cacheTag, cacheData, read);

parameter indexBits = 14;
parameter lineSize = 512;
parameter tagBits = 12;
parameter ways = 8;

input index[indexBits - 1:0];
input addressTag[tagBits - 1:0];
input read;

output cacheData[lineSize -1:0];
output cacheTag[tagBits - 1:0];

reg[lineSize - 1:0] cacheData;
reg[tagBits - 1:0] cacheTag;

typedef struct {
  bit[tagBits - 1:0] cacheTag;
  bit[lineSize - 1:0] cacheData;
  bit[3:0] mesi;
  bit[$clog2(ways) - 1:0] lru;
  } set;

task UpdateLRU  (input index[indexBits - 1:0], way[$clog2(ways) - 1:0]);
  begin
    // Loop through the set array at row[index]
    // Store LRU bits for each way
    // Run LRU logic to update fields given
    // which way is being read/written to
  end
endtask

task QueryLRU (input index[indexBits - 1:0],
               output way[$clog2(ways) - 1:0]);
  begin
    // Loop through the set array at row[index]
    // Store LRU bits for each way
    // Return way for which the LRU bits
    // designate as the oldest.
  end
endtask

// Generate n ways using n structs x m sets
set Storage[$clog2(ways) - 1:0][indexBits - 1:0];

always@(index or addressTag or read)
begin
  if (read)
  begin
    // read cache
    // update LRU
  end
  else if (!read)
  begin
    // read for ownership on shared bus
    // query LRU for way to select
    // write cache
    // update LRU
  end
end
endmodule
