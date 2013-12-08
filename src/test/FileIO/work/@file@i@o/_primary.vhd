library verilog;
use verilog.vl_types.all;
entity FileIO is
    generic(
        addressSize     : integer := 32;
        commandSize     : integer := 32
    );
    port(
        L1Bus           : inout  vl_logic_vector(511 downto 0);
        L1OperationBus  : inout  vl_logic_vector(15 downto 0);
        sharedBus       : inout  vl_logic_vector(511 downto 0);
        sharedOperationBus: inout  vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of addressSize : constant is 1;
    attribute mti_svvh_generic_type of commandSize : constant is 1;
end FileIO;
