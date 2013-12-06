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

  // Keeps track of the way that our LRU is telling us to read/write to
  reg[$clog2(ways) - 1:0] selectedWay;

  // Stores the data and tag in a cache line to be sent to the output block
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

// Loop through the set array at row[index]
// Set the way to the least recently used column
  task QueryLRU;
    begin
      automatic integer LRUvalue = 0;
      automatic bit[indexBits - 1:0] Index;
      automatic integer i;

      // Assign unpacked index input to our word using
      // the streaming operator
      {>>{Index}} = index;

      for (i = 0;i < ways; i = i + 1)
        if (Storage[i][Index].lru > LRUvalue)
        begin
          LRUvalue = Storage[i][Index].lru;
          selectedWay = i;
        end
      end
  endtask

  task UpdateLRU;
    begin
      automatic bit[indexBits - 1:0] Index;
      automatic integer i, j;

      // Array to store the LRU bits from each way
      reg[$clog2(ways) - 1:0][$clog2(ways) - 1:0] LRUbits;

      // Assign unpacked index input to our word using
      // the streaming operator
      {>>{Index}} = index;

      // Loop through the set array at row[index]
      // Store each lru bit in the way in to the matching
      // position in the temporary LRUbits array
      for (i = 0; i < ($clog2(ways) - 1); i = i + 1)
        for (j = 0; j < ($clog2(ways) - 1); j = j  +1)
          LRUbits[i][j] = Storage[i][Index].lru[j];

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
        QueryLRU;
        // write cache
        // update LRU
      end
    end
    endmodule
