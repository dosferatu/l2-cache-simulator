/* This lays out the Finite State Machine (FSM) that will control most of the operations within the cache memory.
 *  It is primarily dependent on the MESI protocol and the need to maitain the inclusivity property.  It is based
 *  on the two example FSMs in the cache slides provided by Professor Mark Faust and the the FSM implemented
 *  by PowerPC to do the same.
 */

module MESI_FSM(COMMAND, STATE_IN, HM, STATE_OUT);
  
  // Declare input/output types, sizes, and uses
  input       [7:0] COMMAND;              // The command of the currently working operation
  input       [3:0] STATE_IN;             // The current state of the working address
  input       [1:0] HM;                   // Takes the HIT/HITM/MISS signals from FSB: 0 MISS, 1 HIT, 2 HITM
  output reg  [3:0] STATE_OUT;            // The next state of the address according to other inputs and MESI FSM
  
  // Establish needed variables and parameters
  localparam    MODIFIED    = 4'b0001;    // Params used for MESI protocol
  localparam    EXCLUSIVE   = 4'b0010;
  localparam    SHARED      = 4'b0100;
  localparam    INVALID     = 4'b1000;


  /**********************************************************************************************************/
  /*  The following is the finite state machine that will perform the appropriate operations for the MESI   */
  /*   protocol.  It will take into account the current state and any other necessary input to determine    */
  /*   the next state.                                                                                      */
  /**********************************************************************************************************/
  
  
  // Gives next state
  always @(STATE_IN,COMMAND,HM)
  begin
    case(STATE_IN)
      MODIFIED:   if      (COMMAND == 0) STATE_OUT = MODIFIED;
                  else if (COMMAND == 1) STATE_OUT = MODIFIED;
                  else if (COMMAND == 2) STATE_OUT = MODIFIED;  // not sure because should not happen?
                  else if (COMMAND == 3) STATE_OUT = MODIFIED;  // not sure because should not happen?
                  else if (COMMAND == 4) STATE_OUT = SHARED;
                  else if (COMMAND == 5) STATE_OUT = MODIFIED;  // not sure because should not happen?
                  else if (COMMAND == 6) STATE_OUT = INVALID;
                  else                   STATE_OUT = MODIFIED;

      EXCLUSIVE:  if      (COMMAND == 0) STATE_OUT = EXCLUSIVE;
                  else if (COMMAND == 1) STATE_OUT = MODIFIED;
                  else if (COMMAND == 2) STATE_OUT = EXCLUSIVE;
                  else if (COMMAND == 3) STATE_OUT = INVALID;
                  else if (COMMAND == 4) STATE_OUT = SHARED;
                  else if (COMMAND == 5) STATE_OUT = EXCLUSIVE;  // not sure because should not happen?
                  else if (COMMAND == 6) STATE_OUT = INVALID;
                  else                   STATE_OUT = EXCLUSIVE;

      SHARED:     if      (COMMAND == 0) STATE_OUT = SHARED;
                  else if (COMMAND == 1) STATE_OUT = MODIFIED;
                  else if (COMMAND == 2) STATE_OUT = SHARED;
                  else if (COMMAND == 3) STATE_OUT = SHARED;  // not sure because should not happen?
                  else if (COMMAND == 4) STATE_OUT = SHARED;
                  else if (COMMAND == 5) STATE_OUT = SHARED;  // not sure because should not happen?
                  else if (COMMAND == 6) STATE_OUT = INVALID;
                  else                   STATE_OUT = SHARED;

      INVALID:    if      (COMMAND == 0) begin
                    if    (HM >= 2'b1)   STATE_OUT = SHARED;
                    else if (HM == 2'b0) STATE_OUT = EXCLUSIVE;
                    else                 STATE_OUT = INVALID;
                  end
                  else if (COMMAND == 1) STATE_OUT = MODIFIED; // This needs more thought
                  else if (COMMAND == 2) begin
                    if    (HM >= 2'b1)   STATE_OUT = SHARED;
                    else if (HM == 2'b0) STATE_OUT = EXCLUSIVE;
                    else                 STATE_OUT = INVALID;
                  end
                  else if (COMMAND == 3) STATE_OUT = INVALID;  // not sure because should not happen?
                  else if (COMMAND == 4) STATE_OUT = SHARED;
                  else if (COMMAND == 5) STATE_OUT = INVALID;  // not sure because should not happen?
                  else if (COMMAND == 6) STATE_OUT = INVALID;
                  else                   STATE_OUT = INVALID;
    endcase
  end
endmodule