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
