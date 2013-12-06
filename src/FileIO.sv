module FileIO(L1Bus,sharedBus,operationBus);
  // Establish parameters for configurability
  parameter addressSize     = 32;
  parameter commandSize     = 32;
  
  // Define inputs and outputs
  inout [255:0]   L1Bus;
  inout [511:0]   sharedBus;
  inout [7:0]     operationBus;

  
  // File handle and I/O function return value
  integer file;
  integer line;

  // Buffers to store the parsed in command and address
  reg   [commandSize - 1:0]   command;
  reg   [addressSize - 1:0]   address;
  //wire  [addressSize - 1:0]   L1address;
  //wire  [addressSize - 1:0]   sharedAddress;
  
  
  // Begin File IO -> Bus procedure
  initial begin
    // Open the trace file and start parsing in each line
    file = $fopen("cc1.din", "r");

    while(!$feof(file)) begin
      line = $fscanf(file, "%h %h", command, address);
    end
  end
/*
    always @(command) begin
      case(command)
        0:  
              // L1 data cache read request
              $display("L1 data cache read request to address %h", address);
              L1Bus <= address;
              operationBus <= 2'd82;
        1:
          // L1 data cache write request
          $display("L1 data cache write request to address %h", address);
          
        2:
          // L1 instruction cache read request
          $display("L1 instruction cache read request to address %h", address);
          
        3:
          // Snooped invalidate command
          $display("Snooped invalidate command to address %h", address);
          
        4:
          // Snooped read request
          $display("Snooped read request to address %h", address);
          
        5:
          // Snooped write request
          $display("Snooped write request to address %h", address);
          
        6:
          // Snooped read with intent to modify
          $display("Snooped read with intent to modify to address %h", address);
          
        8:
          // Clear cache & reset all states
          $display("Clear cache & reset all states");
          
        9:
          // Print contents and state of each valid
          $display("Print contents and state of each valid");
          // cache line (allow subsequent trace activity
      endcase
    end
  end*/
endmodule
