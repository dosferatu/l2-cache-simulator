module FileIO_test();
  wire [255:0] L1Bus;
  wire [511:0] sharedBus;
  wire [7:0]   sharedOperationBus;
  wire [1:0]   snoopBus;
  
  
  FileIO trial(L1Bus,sharedBus,sharedOperationBus);
  
  GetSnoopResult snoop(sharedBus,sharedOperationBus,snoopBus);
  
  initial begin
    $display("L1Bus       SharedBus         sharedOperationBus        snoopBus");
    $monitor("%8h          %8h                %c          %h",L1Bus,sharedBus,sharedOperationBus,snoopBus);
  end
  
endmodule
