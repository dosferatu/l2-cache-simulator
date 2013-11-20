// Here's the cool verilog file for our project.

module cache (
  command,    // Command input
  L1BUS,      // Bus to the L1 cache
  SHAREDBUS,  // Shared bus amongst processors and DRAM
  SNOOPBUS);  // Bus for snoop requests

input command;

inout L1BUS;
inout SHAREDBUS;
inout SNOOPBUS;

wire command;
wire L1BUS;
wire SHAREDBUS;
wire SNOOPBUS;

endmodule
