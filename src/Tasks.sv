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
task SnoopedRFO ();
	if(hitFlag) begin
		case(Storage[selectedWay][index].mesi)
			M: begin
				snoopBusReg <= 2'b10;
				sharedBusReg <= Storage[selectedWay][index].cacheData;
				Storage[selectedWay][index].mesi = I;
				Storage[selectedWay][index].lru = 3;
			end
			E: begin
				snoopBusReg <= 2'b01;
				sharedBusReg <= Storage[selectedWay][index].cacheData;
				Storage[selectedWay][index].mesi = I;
				Storage[selectedWay][index].lru = 3;
			end
			S: begin
				snoopBusReg <= 2'b01;
				Storage[selectedWay][index].mesi = I;
				Storage[selectedWay][index].lru = 3;
			end
			I: // Do nothing
endtask

// Clear cache & reset all states
task ClearL2 ();
	automatic integer i,j;
    automatic integer sets = 2**indexBits;

    for (i = 0; i < ways; i = i + 1) begin
      for (j = 0; j < sets; j = j + 1) begin
        Storage[i][j].mesi = I;
		Storage[i][j].lru = 0;
      end
    end
endtask

// Print contents and state of each valid
task DisplayValid ();
	automatic integer i,j;
    automatic integer sets = 2**indexBits;

    for (i = 0; i < ways; i = i + 1) begin
      for (j = 0; j < sets; j = j + 1) begin
        if(Storage[i][j].mesi != I);
			$display("Way: %d \t Index: %h \t MESI: %b \t LRU: %d", i, j, Storage[i][j].mesi, Storage[i][j].lru);
      end
    end
endtask

