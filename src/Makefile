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
SRC = HitDetection.v
TESTBENCH = 
TOPMODULE = HitDetection.v
###############################################################################
# BE CAREFUL WHEN CHANGING ITEMS BELOW THIS LINE
###############################################################################
#TOOLS
COMPILER = vlog
SIMULATOR = vsim
#TOOL OPTIONS
SFLAGS = -c
SOPTIONS = -do 'run -all'
###############################################################################
#MAKE DIRECTIVES
check : $(TESTBENCH) $(SRC)
	$(COMPILER) $(SRC)

simulate: $(COUTPUT)
	$(SIMULATOR) $(SFLAGS) $(TOPMODULE) $(SOPTIONS)
