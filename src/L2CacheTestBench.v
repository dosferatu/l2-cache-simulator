//**************************************************
// Test bench for the L2 cache
//**************************************************

module L2CacheTestBench();

// Configurable params for the architecture used
parameter commandSize = 8;
parameter instructionSize = 32;

// File handle and I/O function return value
integer file;
integer line;

// Buffers to store the parsed in command and address
reg[commandSize - 1:0] command;
reg[instructionSize - 1:0] address;

initial
begin
  // Open the trace file and start parsing in each line
  file = $fopen("cc1.din", "r");

  while(!$feof(file))
    begin
      line = $fscanf(file, "%h %h", command, address);

      case(command)
        0:
          // L1 data cache read request
          $display("L1 data cache read request to address %h", address);
          
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
end
endmodule
