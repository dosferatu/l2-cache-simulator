module task_global(temp_in,temp_out);

  output reg [7:0] temp_out;
  input [7:0] temp_in;
  
  
  task convert;
    begin
      temp_out = (9/5) * ( temp_in + 32);
    end
  endtask  
  
  always @(temp_in) begin
    convert;
  end


endmodule
