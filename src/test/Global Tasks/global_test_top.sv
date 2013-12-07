module global_test_top();
  reg [7:0] temp_in;
  wire [7:0] temp_out;
  
  task_global m(temp_in,temp_out);
   
  integer i;
  
  initial begin
    for(i = 0; i < 100; i = i + 1)
      #10 temp_in = i;
  end
  
  initial begin
    $display("temp_in       temp_out");
    $monitor("  %d            %d",temp_in, temp_out);
  end
endmodule