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
	for (i=0,i<ways,++i)
	 for (j=0,j<$clog2(ways),++j)
	 LRUbits[j][i]=set[i][index].LRUbits[j][i];
	
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

task QueryLRU (input index[indexBits - 1:0],
               output way[$clog2(ways) - 1:0]);
  begin
    // Loop through the set array at row[index]
	// Store LRU bits for each way
	 for (i=0,i<ways,++i)
	 for (j=0,j<$clog2(ways),++j)
	 LRUbits[j][i]=set[i][index].LRUbits[j][i];

	// Check to see which is the least recently used
	integer LRUvalue = 0;
    
	 for (i=0,i<ways,++i)
	 if(LRUbits[i][$clog2(ways)-1:0]>LRUbits)
	 begin
	 LRU value= LRUbits[i][$clog2(ways)-1:0];
	 way= i;
	 end
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
  else
  begin
    // read for ownership on shared bus
    // query LRU for way to select
    // write cache
    // update LRU
  end
end
endmodule
