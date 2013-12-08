module FileIO(L1Bus,sharedBus,L1OperationBus,sharedOperationBus);
  // Establish parameters for configurability
  parameter stats           = 1;
  parameter addressSize     = 32;
  parameter commandSize     = 32;
  
  // Define inputs and outputs
  inout logic [255:0]   L1Bus;
  inout logic [511:0]   sharedBus;
  inout logic [15:0]    L1OperationBus;
  inout logic [7:0]     sharedOperationBus;
  
  // File handle and I/O function return value
  integer file;
  integer line;
  reg [255:0] L1Address;
  reg [511:0] sharedAddress;
  reg [15:0]  L1Operation;
  reg [7:0]   sharedOperation;

  // Buffers to store the parsed in command and address
  reg   [commandSize - 1:0]   command;
  reg   [addressSize - 1:0]   address;
  
  
  // Assignments for working the bidirection ports
  assign L1Bus              = L1Address;
  assign sharedBus          = sharedAddress;
  assign L1OperationBus     = L1Operation;
  assign sharedOperationBus = sharedOperation;
  
  
  // Begin File IO -> Bus procedure
  initial begin
    // Open the trace file and start parsing in each line
    file = $fopen("cc1.din", "r");

    while(!$feof(file)) begin
      #10 line = $fscanf(file, "%h %h", command, address);
    end
    
    $fclose(file);
  end

    always @(command) begin
      if(stats == 1)
      case(command)
        0:  begin
              // L1 data cache read request
              $display("L1 data cache read request to address %h", address);
              L1Address   <= address;
              L1Operation <= "DR";
            end
        1:  begin
              // L1 data cache write request
              $display("L1 data cache write request to address %h", address);
              L1Address   <= address;
              L1Operation <= "DW";
            end
        2:  begin
              // L1 instruction cache read request
              $display("L1 instruction cache read request to address %h", address);
              L1Address   <= address;
              L1Operation <= "IR";
            end  
        3:  begin
              // Snooped invalidate command
              $display("Snooped invalidate command to address %h", address);
              sharedAddress   <= address;
              sharedOperation <= "I";
            end
        4:  begin
              // Snooped read request
              $display("Snooped read request to address %h", address);
              sharedAddress   <= address;
              sharedOperation <= "R";
            end
        5:  begin
              // Snooped write request
              $display("Snooped write request to address %h", address);
              sharedAddress   <= address;
              sharedOperation <= "W";
            end
        6:  begin
              // Snooped read with intent to modify
              $display("Snooped read with intent to modify to address %h", address);
              sharedAddress   <= address;
              sharedOperation <= "M";
            end
        8:  begin
              // Clear cache & reset all states
              $display("Clear cache & reset all states");
            end
        9:  begin
              // Print contents and state of each valid
              $display("Print contents and state of each valid");
            end
          // cache line (allow subsequent trace activity
      endcase
    end
endmodule

