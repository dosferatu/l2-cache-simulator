//**************************************************
// L2 Cache module
//
//**************************************************

module L2Cache(L1BusIn, L1BusOut, L1OperationBusIn, sharedBusIn, sharedBusOut, sharedOperationBusIn, sharedOperationBusOut, snoopBusIn, snoopBusOut, hit, miss, read, write);

/*************************************************************************************************************/
/*                                       This section establishes parameters                                 */
/*                                    and defines input/outputs for the module.                              */
/*                                        It also initializes variables for                                  */
/*                                                use by the module.                                         */
/*************************************************************************************************************/
  // Establish parameters that can be used for dynamic sizing of cache
  parameter addressSize     = 32;   // Instruction size used by architecture
  parameter byteSelectBits  = 6;    // Number of byte select bits according to line size
  parameter indexBits       = 14;   // Number of bits from the address used for indexing to a set in way
  parameter lineSize        = 512;  // Size of the line of data in a set and used for shared bus size
  parameter L1BusSize       = 256;  // Size of Bus to communicate with the L1
  parameter tagBits         = 12;   // Number of bits from the address used for tag for validating index
  parameter ways            = 8;    // Number of ways for set associativity
  parameter M               = 1;    //
  parameter E               = 2;    //
  parameter S               = 4;    //
  parameter I               = 8;    //  
  parameter HIT             = 2'b01;
  parameter HITM            = 2'b10;
  parameter MISS            = 2'b00;
  parameter IS_L1_BUS       = 1;    // Flag indicating the hit check needs to keep statistics and set selected way
  parameter IS_NOT_L1_BUS   = 0;    // Flag indicating the hit check does not keep stats or set selected way
  parameter display         = 1;    // Set display flag

  // Declare inputs and outputs
  input       [lineSize - 1:0]  sharedBusIn;
  output reg  [lineSize - 1:0]  sharedBusOut;
  input       [255:0]           L1BusIn;
  output reg  [255:0]           L1BusOut;
  input       [15:0]            L1OperationBusIn;
  input       [7:0]             sharedOperationBusIn;
  output reg  [7:0]             sharedOperationBusOut;
  input       [1:0]             snoopBusIn;
  output reg  [1:0]             snoopBusOut;

  output reg  [31:0]            hit;
  output reg  [31:0]            miss;
  output reg  [31:0]            read;
  output reg  [31:0]            write;

  // Establish regs/registers for use by the module
  reg  [lineSize - 1:0]       addressIn;    // Used for holding the address that came in but has not been dissected
  wire [addressSize - 1:0]    address;      // Reg to store current working address
  wire [tagBits - 1:0]        addressTag;   // Current operation's tag from address
  wire [byteSelectBits - 1:0] byteSelect;   // Current byte select value
  reg  [lineSize - 1:0]       cacheData;    // Data from the cache line being operated on
  reg  [tagBits - 1:0]        cacheTag;     // Tag from the cache line being operated on
  reg                         hitFlag;      // Stores whether a hit has occurred or not
  reg                         readFlag;     // Stores whether we are doing a read or a write operation
  reg                         writeFlag;    // 
  reg [indexBits - 1:0]       index;        // Currently selected set
  reg [$clog2(ways) - 1:0]    selectedWay;  // Current operation's selected way according to LRU

  wire [ways - 1:0]           COMPARATOR_OUT;       
  wire [$clog2(ways) - 1:0]   ENCODER_OUT;
  wire [lineSize - 1:0]       MUX_OUT;

  initial begin
    // Initialize statistics
    hit   = 0;
    miss  = 0;
    read  = 0;
    write = 0;
  end
  
  always @(L1BusIn,sharedBusIn) begin
    if(L1BusIn)
      addressIn = L1BusIn;
    else if(sharedBusIn)
      addressIn = sharedBusIn;
  end
  
/*************************************************************************************************************/
/*                                       This section establishes the cache                                  */
/*                                    data structure as a two dimensional array                              */
/*                                        of structures with data mebers:                                    */
/*                                        cacheTag, cacheData, mesi, lru                                     */
/*************************************************************************************************************/
  
  // Cache line structure
  typedef struct {
    bit[tagBits - 1:0] cacheTag;
    bit[lineSize - 1:0] cacheData;
    bit[3:0] mesi;
    bit[$clog2(ways) - 1:0] lru;
  } line;  
  
  // Generate n ways using n structs x m sets
  line Storage[ways - 1:0][2**indexBits - 1:0];

  // Initialize the L2 cache storage to an empty and invalidated state
  initial begin
    automatic integer i,j;
    automatic integer sets = 2**indexBits;

    for (i = 0; i < ways; i = i + 1) begin
      for (j = 0; j < sets; j = j + 1) begin
        Storage[i][j].cacheTag = 0;
        Storage[i][j].cacheData = 0;
        Storage[i][j].mesi = I;
        Storage[i][j].lru = 0;
      end
    end
  end


/*************************************************************************************************************/
/*                                     This section establishes the comparator                               */
/*                                  and multiplexor that will be used to check for                           */
/*                                    hits and get the data from the data cache                              */
/*************************************************************************************************************/

  // Dissect the address into the appropriate parts
  addressDissector #(.addressSize(addressSize), .byteSelectBits(byteSelectBits), .indexBits(indexBits), .lineSize(lineSize), .tagBits(tagBits)) dissector(addressIn,address,addressTag,byteSelect,index);

  // Generate parameter "ways" amount of comparators
  genvar i;
  generate
    for (i = 0; i < ways; i = i + 1) begin: comp
      Comparator #(.addressSize(addressSize), .tagBits(tagBits)) comparator(address,addressTag, Storage[i][index].cacheTag, COMPARATOR_OUT[i]);
    end
  endgenerate

  // Instantiate our encoder for n ways
  Encoder #(ways) encoder(COMPARATOR_OUT, ENCODER_OUT);

  // Wire up the cache data lines to the bus for the multiplexor input
  //  This is set up to allow as much as many as 16 ways
  
  reg [lineSize - 1:0] gnd;
  initial begin
    gnd = 0;
  end
  case (ways)
    1: Multiplexor #(ways)  multiplexor(.select(ENCODER_OUT),
      .in0(Storage[0][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in1(gnd),
      .in2(gnd),
      .in3(gnd),
      .in4(gnd),
      .in5(gnd),
      .in6(gnd),
      .in7(gnd),
      .in8(gnd),
      .in9(gnd),
      .in10(gnd),
      .in11(gnd),
      .in12(gnd),
      .in13(gnd),
      .in14(gnd),
      .in15(gnd),
      .out(MUX_OUT));
    2: Multiplexor #(ways)  multiplexor(.select(ENCODER_OUT),
      .in0(Storage[0][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in1(Storage[1][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in2(gnd),
      .in3(gnd),
      .in4(gnd),
      .in5(gnd),
      .in6(gnd),
      .in7(gnd),
      .in8(gnd),
      .in9(gnd),
      .in10(gnd),
      .in11(gnd),
      .in12(gnd),
      .in13(gnd),
      .in14(gnd),
      .in15(gnd),
      .out(MUX_OUT));
    4: Multiplexor #(ways)  multiplexor(.select(ENCODER_OUT),
      .in0(Storage[0][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in1(Storage[1][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in2(Storage[2][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in3(Storage[3][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in4(gnd),
      .in5(gnd),
      .in6(gnd),
      .in7(gnd),
      .in8(gnd),
      .in9(gnd),
      .in10(gnd),
      .in11(gnd),
      .in12(gnd),
      .in13(gnd),
      .in14(gnd),
      .in15(gnd),
      .out(MUX_OUT));
    8: Multiplexor #(ways)  multiplexor(.select(ENCODER_OUT),
      .in0(Storage[0][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in1(Storage[1][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in2(Storage[2][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in3(Storage[3][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in4(Storage[4][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in5(Storage[5][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in6(Storage[6][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in7(Storage[7][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in8(gnd),
      .in9(gnd),
      .in10(gnd),
      .in11(gnd),
      .in12(gnd),
      .in13(gnd),
      .in14(gnd),
      .in15(gnd),
      .out(MUX_OUT));
    16: Multiplexor #(ways)  multiplexor(.select(ENCODER_OUT),
      .in0(Storage[0][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in1(Storage[1][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in2(Storage[2][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in3(Storage[3][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in4(Storage[4][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in5(Storage[5][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in6(Storage[6][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in7(Storage[7][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in8(Storage[8][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in9(Storage[9][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in10(Storage[10][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in11(Storage[11][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in12(Storage[12][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in13(Storage[13][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in14(Storage[14][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .in15(Storage[15][L1BusIn[byteSelectBits + indexBits - 1:0]].cacheData),
      .out(MUX_OUT));
  endcase


/*************************************************************************************************************/
/*                                     This section establishes has the                                      */
/*                                  operations that will occur dependent on                                  */
/*                                    the inputs and states of the cache                                     */
/*************************************************************************************************************/

  // Performs necessary tasks/functions depending on whether there is a read or right to the cache
  always@(L1BusIn, L1OperationBusIn, sharedBusIn, sharedOperationBusIn) begin

    // Command 0
    // Read request from L1 data cache
    if (L1OperationBusIn == "DR") begin
      // Update the cache
      CheckForHit(L1BusIn, IS_L1_BUS);
      
      if (hitFlag) begin
        case (Storage[selectedWay][index].mesi)
          M: begin
            ReadL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = M;
            WriteL1;
          end

          E: begin
            ReadL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = E;
            WriteL1;
          end

          S: begin
            ReadL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = S;
            WriteL1;
          end

          I: begin
            ReadSharedBus("R"); // Read
            if (snoopBusIn == HIT || snoopBusIn == HITM) begin // HIT/HITM
              WriteL2Cache;
              UpdateLRU;
              Storage[selectedWay][index].mesi = S;
              WriteL1;
            end

            else if (snoopBusIn == MISS) begin // MISS
              ReadSharedBus("M");  // RFO
              WriteL2Cache;
              UpdateLRU;
              Storage[selectedWay][index].mesi = E;
              WriteL1;
            end
          end
        endcase
      end

      else if (~hitFlag) begin
        ReadSharedBus("R"); // Read
        if (snoopBusIn == HIT || snoopBusIn == HITM) begin // HIT/HITM
          WriteL2Cache;
          UpdateLRU;
          Storage[selectedWay][index].mesi = S;
          WriteL1;
        end

        else if (snoopBusIn == MISS) begin // MISS
          ReadSharedBus("M"); // RFO
          WriteL2Cache;
          UpdateLRU;
          Storage[selectedWay][index].mesi = E;
          WriteL1;
        end;
      end

      if (display == 1)
        DisplayState(L1OperationBusIn);
    end

    // Command 1
    // Write request from L1 data cache
    else if (L1OperationBusIn == "DW") begin
      // Update the cache
      CheckForHit(L1BusIn, IS_L1_BUS);

      if (hitFlag) begin
        case (Storage[selectedWay][index].mesi)
          M: begin
            WriteL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = M;
          end

          E: begin
            SendInvalidate;
            WriteL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = M;
          end

          S: begin
            SendInvalidate;
            WriteL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = M;
          end

          I: begin
            ReadSharedBus("R"); // Read
            case (snoopBusIn)
              HIT: begin
                WriteL2Cache;
                UpdateLRU;
                Storage[selectedWay][index].mesi = M;
              end

              HITM: begin
                ReadSharedBus("M"); // RFO
                WriteL2Cache;
                UpdateLRU;
                Storage[selectedWay][index].mesi = M;
              end

              MISS: begin
                WriteL2Cache;
                UpdateLRU;
                Storage[selectedWay][index].mesi = M;
              end
            endcase
          end
        endcase
      end

      else if (~hitFlag) begin
        ReadSharedBus("R"); // Read
        case (snoopBusIn)
          HIT: begin
            WriteL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = M;
          end

          HITM: begin
            ReadSharedBus("M"); // RFO
            WriteL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = M;
          end

          MISS: begin
            WriteL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = M;
          end
        endcase
      end

      if (display == 1)
        DisplayState(L1OperationBusIn);
    end

    // Command 2
    // Read request from L1 instruction cache
    else if (L1OperationBusIn == "IR") begin
      // Update the cache
      CheckForHit(L1BusIn, IS_L1_BUS);

      if (hitFlag) begin
        case (Storage[selectedWay][index].mesi)
          M: begin
            ReadL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = M;
            WriteL1;
          end

          E: begin
            ReadL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = E;
            WriteL1;
          end

          S: begin
            ReadL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = S;
            WriteL1;
          end

          I: begin
            ReadSharedBus("R"); // Read
            case (snoopBusIn)
              HIT: begin
                WriteL2Cache;
                UpdateLRU;
                Storage[selectedWay][index].mesi = S;
                WriteL1;
              end

              HITM: begin
                ReadSharedBus("M"); // RFO
                WriteL2Cache;
                UpdateLRU;
                Storage[selectedWay][index].mesi = E;
              end

              MISS: begin
                WriteL2Cache;
                UpdateLRU;
                Storage[selectedWay][index].mesi = E;
                WriteL1;
              end
            endcase
          end
        endcase
      end

      else if (~hitFlag) begin
        ReadSharedBus("R"); // Read
        case (snoopBusIn)
          HIT: begin
            WriteL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = S;
          end

          HITM: begin
            WriteL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = S;
          end

          MISS: begin
            ReadSharedBus("R"); // Read
            WriteL2Cache;
            UpdateLRU;
            Storage[selectedWay][index].mesi = E;
            WriteL1;
          end
        endcase
      end

      if (display == 1)
        DisplayState(L1OperationBusIn);
    end

    // Command 3
    // Snooped invalidate command (another processor is modifying the data)
    else if (sharedOperationBusIn == "I") begin
      // Update the cache
      CheckForHit(sharedBusIn, IS_NOT_L1_BUS);

      if (hitFlag) begin
        case (Storage[selectedWay][index].mesi)
          M: begin
            PutSnoopResult;
            WriteSharedBus;
            InvalidateL2;
          end

          E: begin
            InvalidateL2;
          end

          S: begin
            InvalidateL2;
          end

          I: begin
          end
        endcase
      end

      else if (~hitFlag) begin
      end

      if (display == 1)
        DisplayState(sharedOperationBusIn);
    end

    // Command 4
    // Snooped read request (another processor is trying to read)
    else if (sharedOperationBusIn == "R") begin
      // Update the cache
      CheckForHit(sharedBusIn, IS_NOT_L1_BUS);

      if (hitFlag) begin
        case (Storage[selectedWay][index].mesi)
          M: begin
            PutSnoopResult;
            WriteSharedBus;
            UpdateLRU;
            Storage[selectedWay][index].mesi = S;
          end

          E: begin
            PutSnoopResult;
            UpdateLRU;
            Storage[selectedWay][index].mesi = S;
          end

          S: begin
            PutSnoopResult;
            UpdateLRU;
            Storage[selectedWay][index].mesi = S;
          end

          I: begin
          end
        endcase
      end

      else if (~hitFlag) begin
        PutSnoopResult;
      end

      if (display == 1)
        DisplayState(sharedOperationBusIn);
    end

    // Command 5
    // Snooped write request (another processor is trying to write)
    else if (sharedOperationBusIn == "W") begin
      // Update the cache
      CheckForHit(sharedBusIn, IS_NOT_L1_BUS);

      if (hitFlag) begin
        case (Storage[selectedWay][index].mesi)
          M: begin
            PutSnoopResult;
            WriteSharedBus;
            Storage[selectedWay][index].mesi = I;
          end

          E: begin
            Storage[selectedWay][index].mesi = I;
          end

          S: begin
            Storage[selectedWay][index].mesi = I;
          end

          I: begin
          end
        endcase
      end

      else if (~hitFlag) begin
      end

      if (display == 1)
        DisplayState(sharedOperationBusIn);
    end

    // Command 6
    // Snooped read with intent to modify (another processor has ownership and
    // we are snooping
    else if (sharedOperationBusIn == "M") begin
      // Update the cache
      CheckForHit(sharedBusIn, IS_NOT_L1_BUS);

      if (hitFlag) begin
        case (Storage[selectedWay][index].mesi)
          M: begin
            PutSnoopResult;
            WriteSharedBus;
            Storage[selectedWay][index].mesi = I;
          end

          E: begin
            Storage[selectedWay][index].mesi = I;
          end

          S: begin
            Storage[selectedWay][index].mesi = I;
          end

          I: begin
          end
        endcase
      end

      else if (~hitFlag) begin
      end

      if (display == 1)
        DisplayState(sharedOperationBusIn);
    end

    // Command 8
    else if (L1OperationBusIn == "CL")
      ClearL2;

    // Command 9
    else if (L1OperationBusIn == "PR") begin
      DisplayValid;
    end
  end



/*************************************************************************************************************/
/*                                    This section defines tasks that will                                   */
/*                                  will be used by the L2Cache module to perform                            */
/*                                      appropriate operations on the cache                                  */
/*                                        dependent upon the cache inputs                                    */
/*************************************************************************************************************/

  task DisplayState (input[15:0] operation); begin
    automatic integer i;
    automatic string mesiStatus;

    // Display all elements of the current operation
    $display("Command: %s", operation);
    $display("L1 Bus (Hex): %h", L1BusIn[addressSize - 1:0]);
    $display("Shared Bus (Hex): %h", sharedBusIn[addressSize - 1:0]);
    $display("Address Tag (Hex): %h",addressTag);
    $display("Byte Select (Decimal): %d",byteSelect);
    $display("Index (Decimal): %d", index);

    // Display whether a hit or a miss
    if (hitFlag) begin
      $display("Cache hit from way: %d", selectedWay);
    end

    else if (~hitFlag) begin
      $display("Cache miss from way: %d", selectedWay);
    end

    // Loop through each way and see what the MESI state is for each
    for (i = 0; i < ways; i = i + 1) begin
      case (Storage[i][index].mesi)
        M: mesiStatus = "M";
        E: mesiStatus = "E";
        S: mesiStatus = "S";
        I: mesiStatus = "I";
      endcase

      if (display) begin
        $display("Way: %d\tLRU Value: %d\tMESI status: %s", i, Storage[i][index].lru, mesiStatus);
        $display("\n");
      end
    end
  end
  endtask

  /****************************************************************************/

  // Update the hit detection flag and set the selected way if necessary.
  task CheckForHit (input [lineSize - 1:0]  addressIn, input isL1); begin
    automatic integer i;
    
    // Initialize hitFlag
    hitFlag = 0;

    // Check for hit from comparator and the mesi bits of the ways
    for (i = 0; i < ways; i = i + 1) begin
      hitFlag = hitFlag | (COMPARATOR_OUT[i] & ~Storage[i][index].mesi[3]);

      if(COMPARATOR_OUT[i] == 1) begin
        if (display) begin
          $display("Hit: %h, Comparator: %h, Valid: %h", hitFlag,COMPARATOR_OUT[i],~Storage[i][index].mesi[3]);
        end
      end
    end
    
    // Only run stats if we are checking for the L1 bus
      // Increment hits and misses
    if (hitFlag) begin
      if(isL1) begin
        hit = hit + 1;
      end
      selectedWay = ENCODER_OUT; 
    end
    else if (!hitFlag) begin
      if(isL1) begin
        miss = miss + 1;
      end
    end
  end
  endtask

/*********************************************************************/

  task WriteL2Cache; begin
    write = write + 1;

    if (hitFlag) begin
      Storage[selectedWay][index].cacheData <= "W";

      if (display) begin
        $display("Write --> Hit Way: %d \t AddressTag: %h \t Index: %h",selectedWay,addressTag,index);
      end
    end
    else if (!hitFlag) begin
      QueryLRU;
      case(Storage[selectedWay][index].mesi)
        M: begin
          WriteSharedBus;
          Storage[selectedWay][index].cacheData <= "W";
          Storage[selectedWay][index].cacheTag <= addressTag;

          if (display) begin
            $display("Write --> Miss Way: %d \t AddressTag: %h \t CacheTag: %h \t Index: %h",selectedWay,addressTag,Storage[selectedWay][index].cacheTag,index);
          end
        end

        E: begin
          Storage[selectedWay][index].cacheData <= "W";
          Storage[selectedWay][index].cacheTag <= addressTag;

          if (display) begin
            $display("Write --> Miss Way: %d \t AddressTag: %h \t CacheTag: %h \t Index: %h",selectedWay,addressTag,Storage[selectedWay][index].cacheTag,index);
          end
        end

        S: begin
          Storage[selectedWay][index].cacheData <= "W";
          Storage[selectedWay][index].cacheTag <= addressTag;

          if (display) begin
            $display("Write --> Miss Way: %d \t AddressTag: %h \t CacheTag: %h \t Index: %h",selectedWay,addressTag,Storage[selectedWay][index].cacheTag,index);
          end
        end

        I: begin
          Storage[selectedWay][index].cacheData <= "W";
          Storage[selectedWay][index].cacheTag <= addressTag;

          if (display) begin
            $display("Write --> Miss Way: %d \t AddressTag: %h \t CacheTag: %h \t Index: %h",selectedWay,addressTag,Storage[selectedWay][index].cacheTag,index);
          end
        end
      endcase
    end
  end
  endtask
  
/****************************************************************************/

  task ReadL2Cache; begin
    read = read + 1;
    WriteL1;
    if(display == 1)
      $display("Read --> Address: %h \t CacheTag: %h",address,Storage[selectedWay][index].cacheTag);
  end
  endtask

/***************************************************************/

  task ReadSharedBus(input [7:0] operation); begin
    if(operation == "R") begin
      if(display == 1)
        $display("ReadShared --> Address: %h \t Operation: R",address);
      sharedOperationBusOut <= operation;
      sharedBusOut          <= address;
    end
    else if(operation == "M") begin
      if(display == 1)
        $display("ReadShared --> Address: %h \t Operation: M",address);
      sharedOperationBusOut <= operation;
      sharedBusOut          <= address;
    end
  end
  endtask

/********************************************************************/

  task WriteSharedBus; begin
    reg   [lineSize - 1:0] newAddress;
    
    assign newAddress = address & 6'b000000;
    if(display == 1)
      $display("WriteShared --> Address: %h \t Operation: W",newAddress);
    sharedBusOut          <= newAddress;
    sharedOperationBusOut <= "W";
  end
  endtask

/*********************************************************************/

  task WriteL1; begin
    if (sharedOperationBusIn == "I") begin
      L1BusOut <= sharedBusIn & 5'b00000;
      if(display == 1)
        $display("WriteL1 --> Address: %h \t Operation: I",L1BusOut);
    end
    else if (L1OperationBusIn == "DR") begin
      L1BusOut <= "L1DR";
      if(display == 1)
        $display("WriteL1 --> Address: %h \t Operation: DR",L1BusOut);
    end
    else if (L1OperationBusIn == "DW") begin
      L1BusOut <= "L1DW";
     if(display == 1)
        $display("WriteL1 --> Address: %h \t Operation: DW",L1BusOut);
    end
    else begin
      L1BusOut <= "L1IR";
      if(display == 1)
        $display("WriteL1 --> Address: %h \t Operation: IR",L1BusOut);
    end
  end
  endtask

/*********************************************************************/

  task SendInvalidate; begin
    sharedBusOut        <= L1BusIn & 5'b00000;
    sharedOperationBusOut  <= "I";

    if(display == 1)
        $display("SharedInvalidate --> Address: %h \t Operation: %h",sharedBusOut,sharedOperationBusOut);

  end
  endtask

/*********************************************************************/

  task InvalidateL2; begin
    // Invalidate line
    Storage[selectedWay][address[byteSelectBits + indexBits - 1:byteSelectBits]].mesi = "I";
    
    // Send L1 Bus address to invalidate     
    L1BusOut = address & 5'b00000;
  end
  endtask

/*********************************************************************/

  // Clear cache & reset all states
  task ClearL2; begin
    automatic integer i,j;
    automatic integer sets = 2**indexBits;

    for (i = 0; i < ways; i = i + 1) begin
      for (j = 0; j < sets; j = j + 1) begin
        Storage[i][j].mesi = I;
        Storage[i][j].lru = 0;
      end
    end
  end
  endtask

/*********************************************************************/

  // Print contents and state of each valid
  task DisplayValid; begin
    automatic integer i,j;
    automatic integer sets = 2**indexBits;
    
    for (i = 0; i < ways; i = i + 1) begin
      for (j = 0; j < sets; j = j + 1) begin
        if(Storage[i][j].mesi != I);
        $display("Way: %d \t Index: %h \t MESI: %b \t LRU: %d", i, j, Storage[i][j].mesi, Storage[i][j].lru);
      end
    end
  end
endtask

/*********************************************************************/

  // Loop through the set array at row[index]
  // Set the way to the least recently used column
  task QueryLRU; begin
    automatic integer LRUvalue = 0;
    automatic integer i;

    // Loop through each way to find which way is LRU
    // i is used to keep track of the current way during the loop
    for (i = 0;i < ways; i = i + 1) begin
      if (Storage[i][index].lru > LRUvalue) begin
        LRUvalue = Storage[i][index].lru;
        selectedWay = i;
      end
    end
  end
  endtask

/*********************************************************************/

  task UpdateLRU; begin
    automatic integer i;

    // Save the selected way's LRU value
    automatic reg[2:0] selectedLRU = Storage[selectedWay][index].lru;

    // Increment through each way at the index to check LRU values and update
    //  them accordingly
    for (i = 0; i < ways; i = i + 1) begin
      if (Storage[i][index].lru <= selectedLRU)
        Storage[i][index].lru = Storage[i][index].lru + 1;
    end

    // Finally set the selected way to the most recently used
    Storage[selectedWay][index].lru = 0;
    end
  endtask
  
/*********************************************************************/

  task PutSnoopResult; begin
    if(display == 1)
      $display("PutSnoopResult");

    if (hitFlag) begin
      case(Storage[selectedWay][index].mesi)
        M: snoopBusOut <= HITM;
        E: snoopBusOut <= HIT;
        S: snoopBusOut <= HIT;
        I: snoopBusOut <= MISS;
        default: snoopBusOut <= MISS;
      endcase
    end
    else if(!hitFlag)
      snoopBusOut = MISS;
  end
  endtask
endmodule
