library verilog;
use verilog.vl_types.all;
entity task_global is
    port(
        temp_in         : in     vl_logic_vector(7 downto 0);
        temp_out        : out    vl_logic_vector(7 downto 0)
    );
end task_global;
