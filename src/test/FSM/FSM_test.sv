`include "MESI_FSM.sv"

module FSM_test();
  
  // Establish variables
  reg [7:0] COMMAND;
  reg [3:0] STATE_IN;
  reg [1:0] HM;
  
  reg [3:0] STATE_OUT;
  
  /*integer i;
  integer j;
  integer k;
  */
  
    // MESI FSM
  always @(COMMAND, STATE_IN, HM)
  begin
    MESI_FSM(COMMAND, STATE_IN, HM, STATE_OUT);
  end

  
  /*
  initial
  begin
    COMMAND = 4'b0;
    for(i = 0;i < 7;i = i + 1)
    begin
      STATE_IN = 4'b0001;
      HM = 0;
      for(j = 0;j < 4;j = j + 1)
      begin
        for(k = 0;k < 3;i = k + 1)
        begin
          #10 HM = HM + 1;
        end
        #10 STATE_IN = STATE_IN << 1;
      end
      #10 COMMAND = COMMAND + 4'b1;
    end
  end*/
  
  initial
  begin
        COMMAND = 0; STATE_IN = 1; HM = 0;
    #10 COMMAND = 1; STATE_IN = 1; HM = 0;
    #10 COMMAND = 2; STATE_IN = 1; HM = 0;
    #10 COMMAND = 3; STATE_IN = 1; HM = 0;
    #10 COMMAND = 4; STATE_IN = 1; HM = 0;
    #10 COMMAND = 5; STATE_IN = 1; HM = 0;
    #10 COMMAND = 6; STATE_IN = 1; HM = 0;
    #10 COMMAND = 0; STATE_IN = 2; HM = 0;
    #10 COMMAND = 1; STATE_IN = 2; HM = 0;
    #10 COMMAND = 2; STATE_IN = 2; HM = 0;
    #10 COMMAND = 3; STATE_IN = 2; HM = 0;
    #10 COMMAND = 4; STATE_IN = 2; HM = 0;
    #10 COMMAND = 5; STATE_IN = 2; HM = 0;
    #10 COMMAND = 6; STATE_IN = 2; HM = 0;
    #10
    $stop;
  end
    
  
  initial
  begin
    $display("                Time      COMMAND       STATE_IN      HM      STATE_OUT");
    $monitor($time, "       %b      %b          %b    %b", COMMAND, STATE_IN, HM, STATE_OUT);
  end
  
endmodule        