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

