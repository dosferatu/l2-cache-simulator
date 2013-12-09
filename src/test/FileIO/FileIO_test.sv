module FileIO_test();
  wire [511:0] L1Bus;
  wire [511:0] sharedBus;
  wire [15:0]  L1OperationBus;
  wire [7:0]   sharedOperationBus;
  wire [1:0]   snoopBus;
  
  
  FileIO trial(L1Bus,L1OperationBus,sharedBus,sharedOperationBus);
  
  GetSnoopResult snoop(sharedBus,sharedOperationBus,snoopBus);
  
  initial begin
    $display("L1Bus       L1OperationBus        SharedBus         sharedOperationBus        snoopBus");
    $monitor("%8h          %s          %8h           %c                %h",L1Bus,L1OperationBus,sharedBus,sharedOperationBus,snoopBus);
  end
  
endmodule
