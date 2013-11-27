/* This layouts the Finite State Machine (FSM) that will control most of the operations within the cache memory.
    It is primarily dependent on the MESI protocol and the need to maitain the inclusivity property.  It is based
    on the two example FSMs in the cache slides provided by Professor Mark Faust and the the FSM implemented
    by PowerPC to do the same.
 */
 
 module cache_FSM(CLK,COMMAND, ADDRESS, );
   input CLK;
   input [31:0] COMMAND, ADDRESS;
   output reg [];
   
   always @(posedge CLK