module GetSnoopResult(sharedBus,sharedOperationBus,snoopBus);
  // Configurable params for dynamic system
  parameter lineSize = 32;
  
  // Establish inputs and outputs of the module
  inout logic [lineSize - 1:0]  sharedBus;
  inout logic [7:0]             sharedOperationBus;
  inout logic [1:0]             snoopBus;
  
  // Registers needed for running the bidir ports
  reg [1:0]                     snoop;
  
  // Assign registers for running the bidir ports
  assign snoopBus = snoop;
  
  // Perform a consistant procedure
  always @(sharedBus, sharedOperationBus) begin
    if(sharedBus[3:0] == 4'h2 || sharedBus[3:0] == 4'h8)
      snoop <= 2'b01;
    else if(sharedBus[3:0] == 4'h4 || sharedBus[3:0] == 4'hC)
      snoop <= 2'b10;
    else
      snoop <= 2'b00;
  end
endmodule
