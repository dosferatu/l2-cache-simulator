library verilog;
use verilog.vl_types.all;
entity GetSnoopResult is
    generic(
        lineSize        : integer := 512
    );
    port(
        sharedBus       : inout  vl_logic_vector;
        sharedOperationBus: inout  vl_logic_vector(7 downto 0);
        snoopBus        : inout  vl_logic_vector(1 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of lineSize : constant is 1;
end GetSnoopResult;
