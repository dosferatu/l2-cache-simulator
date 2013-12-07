library verilog;
use verilog.vl_types.all;
entity cache_FSM is
    port(
        COMMAND         : in     vl_logic_vector(7 downto 0);
        STATE_IN        : in     vl_logic_vector(3 downto 0);
        HM              : in     vl_logic_vector(1 downto 0);
        STATE_OUT       : out    vl_logic_vector(3 downto 0)
    );
end cache_FSM;
