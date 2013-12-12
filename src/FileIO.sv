module FileIO(L1BusIn,L1OperationBusIn,sharedBusIn, sharedOperationBusIn);
  // Establish parameters for configurability
  parameter addressSize = 32;
  parameter commandSize = 32;
  parameter display = 0;
  
  // Define inputs and outputs
  output reg [255:0]   L1BusIn;
  output reg [511:0]   sharedBusIn;
  output reg [15:0]    L1OperationBusIn;
  output reg [7:0]     sharedOperationBusIn;
  
  // File handle and I/O function return value
  integer file;
  integer line;

  // Buffers to store the parsed in command and address
  reg   [commandSize - 1:0]   command;
  reg   [addressSize - 1:0]   address;
  
  // Begin File IO -> Bus procedure
  initial begin
    // Open the trace file and start parsing in each line
    file = $fopen("cc1.din", "r");

    while(!$feof(file)) begin
      #1000 line = $fscanf(file, "%h %h", command, address);
      #1000  command = 32'bz; address = 32'bz;
    end
    L1OperationBusIn = "PS"; // Print stats
  end

    always @(command) begin
      case(command)
        0:  begin
              // L1 data cache read request
              if (display == 1)
                $display("L1 data cache read request to address %h", address);
              L1BusIn               <= address;
              L1OperationBusIn      <= "DR";
              sharedBusIn           <= 32'bz;
              sharedOperationBusIn  <= 8'bz;
            end
        1:  begin
              // L1 data cache write request
              if (display == 1)
                $display("L1 data cache write request to address %h", address);
              L1BusIn               <= address;
              L1OperationBusIn      <= "DW";
              sharedBusIn           <= 32'bz;
              sharedOperationBusIn  <= 8'bz;
            end
        2:  begin
              // L1 instruction cache read request
              if (display == 1)
                $display("L1 instruction cache read request to address %h", address);
              L1BusIn               <= address;
              L1OperationBusIn      <= "IR";
              sharedBusIn           <= 32'bz;
              sharedOperationBusIn  <= 8'bz;
            end  
        3:  begin
              // Snooped invalidate command
              if (display == 1)
                $display("Snooped invalidate command to address %h", address);
              sharedBusIn           <= address;
              sharedOperationBusIn  <= "I";
              L1BusIn               <= 32'bz;
              L1OperationBusIn      <= 8'bz;
            end
        4:  begin
              // Snooped read request
              if (display == 1)
                $display("Snooped read request to address %h", address);
              sharedBusIn           <= address;
              sharedOperationBusIn  <= "R";
              L1BusIn               <= 32'bz;
              L1OperationBusIn      <= 8'bz;
            end
        5:  begin
              // Snooped write request
              if (display == 1)
                $display("Snooped write request to address %h", address);
              sharedBusIn           <= address;
              sharedOperationBusIn  <= "W";
              L1BusIn               <= 32'bz;
              L1OperationBusIn      <= 8'bz;
            end
        6:  begin
              // Snooped read with intent to modify
              if (display == 1)
                $display("Snooped read with intent to modify to address %h", address);
              sharedBusIn           <= address;
              sharedOperationBusIn  <= "M";
              L1BusIn               <= 32'bz;
              L1OperationBusIn      <= 8'bz;
            end
        8:  begin
              // Clear cache & reset all states
              if (display == 1)
                $display("Clear cache & reset all states");
              sharedOperationBusIn <= "CL";
            end
        9:  begin
              // Print contents and state of each valid
              if (display == 1)
                $display("Print contents and state of each valid");
              sharedOperationBusIn <= "PR";
            end
        default: begin
          sharedBusIn           <= address;
          sharedOperationBusIn  <= command;
          L1BusIn               <= address;
          L1OperationBusIn      <= command;
        end
      endcase
    end
endmodule
