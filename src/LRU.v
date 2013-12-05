/* This task will perform the appropriate operation to update the cache LRU counters for each way in the cache.
 *	It will be used in the L2 Cache module whenever a hit is detected or when a new item is added to the cache.
 */
 
 task LRU_Update
	//input index; 	// Index for choosing appropriate set in each way
	//input [??:0] current_way;	// This stores the way that is being accessed and which will be the MRU way
	
	/* Begin at first way and go through each comparing the way to the current way.
	 *	If the way matches, the count goes to zero.
	 *	If the way doesn't match, the count is incremented.
	 *	Over incrementing must be considered so additional checks need to be included
	 */
	 
	 
	 
endtask