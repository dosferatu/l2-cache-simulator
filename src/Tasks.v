//**************************************************
// CACHE ROUTINES
//
// This file contains tasks used by the cache to
// implement cache coherence as well as other
// commonly used routines.
//**************************************************

// L1 data cache read request
task command0 ();
endtask

// L1 data cache write request
task command1 ();
endtask

// L1 instruction cache read request
task command2 ();
endtask

// Snooped invalidate command
task command3 ();
endtask

// Snooped read request
task command4 ();
endtask

// Snooped write request
task command5 ();
endtask

// Snooped read with intent to modify
task command6 ();
endtask

// Clear cache & reset all states
task command8 ();
endtask

// Print contents and state of each valid
task command9 ();
endtask

// Loop through the set array at row[index]
// Set the way to the least recently used column
task QueryLRU (input index[indexBits - 1:0],
               output way[$clog2(ways) - 1:0]);
begin
  integer i;
  integer LRUvalue = 0;

  for (i = 0,i < ways, i = i + 1)
    if (set[i][index].lru > LRUvalue)
    begin
      LRUvalue = set[i][index].lru;
      way = i;
    end
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
    end
  end
endtask
