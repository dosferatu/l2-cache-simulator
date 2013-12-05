//**************************************************
// CACHE ROUTINES
//
// This file contains tasks used by the cache to
// implement cache coherence as well as other
// commonly used routines.
//**************************************************

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
