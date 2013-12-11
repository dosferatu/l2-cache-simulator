module GetSnoopResult(sharedBusOut,sharedOperationBusOut,snoopBusIn);
  // Configurable params for dynamic system
  parameter lineSize = 512;
  
  // Establish inputs and outputs of the module
  input  [lineSize - 1:0]  sharedBusOut;
  input  [7:0]             sharedOperationBusOut;
  output reg [1:0]         snoopBusIn;

  
  // Perform a consistant procedure
  always @(sharedBusOut, sharedOperationBusOut) begin
    if(sharedBusOut[3:0] == 4'h2 || sharedBusOut[3:0] == 4'h8) begin
      snoopBusIn <= 2'b01;
    end
    else if(sharedBusOut[3:0] == 4'h4 || sharedBusOut[3:0] == 4'hC) begin
      snoopBusIn <= 2'b10;
    end
    else begin
      snoopBusIn <= 2'b00;
    end
  end
endmodule
