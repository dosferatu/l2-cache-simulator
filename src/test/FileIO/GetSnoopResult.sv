module GetSnoopResult(sharedBus,sharedOperationBus,snoopBus);
  // Configurable params for dynamic system
  parameter lineSize = 512;
  
  // Establish inputs and outputs of the module
  inout logic [lineSize - 1:0]  sharedBus;
  inout logic [7:0]             sharedOperationBus;
  inout logic [1:0]             snoopBus;
  
  // Registers needed for running the bidir ports
  reg [1:0]                     snoop;
  reg [lineSize - 1:0]			sharedBusnew;
  
  // Assign registers for running the bidir ports
  assign snoopBus = snoop;
  assign sharedBus = sharedBusnew;
  
  // Perform a consistant procedure
  always @(sharedBus, sharedOperationBus) begin
    if(sharedBus[3:0] == 4'h2 || sharedBus[3:0] == 4'h8) begin
      snoop <= 2'b01;  //HIT
	  sharedBusnew <= 32'b111111001001;
    end
    else if(sharedBus[3:0] == 4'h4 || sharedBus[3:0] == 4'hC) begin
      snoop <= 2'b10;  //HITM
	  sharedBusnew <= 32'b111111001001;
    end
    else begin
      snoop <= 2'b00;  //MISS
	  sharedBusnew <= 32'b111111001001;
    end
  end
endmodule
