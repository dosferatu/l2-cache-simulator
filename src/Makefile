###############################################################################
#
# QUESTA MAKEFILE
# 
# USE THE FOLLOWING COMMANDS WITH THIS MAKEFILE
#	"make check" - compiles your verilog design - good for checking code
#	"make simulate" - compiles your design+TB & simulates your design
# 
###############################################################################
#TOOL INPUT
SRC = L2Cache.v
TESTBENCH = L2CacheTestBench.v
TOPMODULE = L2CacheTestBench
###############################################################################
# BE CAREFUL WHEN CHANGING ITEMS BELOW THIS LINE
###############################################################################
#TOOLS
COMPILER = vlog
SIMULATOR = vsim
#TOOL OPTIONS
CFLAGS = -sv
SFLAGS = -c
SOPTIONS = -do 'run -all'
###############################################################################
#MAKE DIRECTIVES
check : $(TESTBENCH) $(SRC)
	$(COMPILER) $(CFLAGS) $(SRC)

simulate: $(COUTPUT)
	$(SIMULATOR) $(SFLAGS) $(TOPMODULE) $(SOPTIONS)
