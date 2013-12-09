//**************************************************
// L2 Cache module
//
//**************************************************

module L2Cache(L1Bus, L1OperationBus, sharedBus, sharedOperationBus, snoopBus, hit, miss, read, write);
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
  parameter display         = 0;    // Set display flag

  // Declare inputs and outputs
  inout logic[L1BusSize - 1:0] L1Bus;               // Bus used for communicating with L1
  inout logic[15:0]            L1OperationBus;      // 
  inout logic[lineSize - 1:0]  sharedBus;           // 
  inout logic[7:0]             sharedOperationBus;  // Bus used to designate read/write/modify/invalidate
  inout logic[1:0]             snoopBus;            // Bus for getting/putting snoops

  reg [L1BusSize - 1:0] L1BusReg;
  reg [15:0]            L1OperationBusReg;
  reg [lineSize - 1:0]  sharedBusReg;
  reg [7:0]             sharedOperationBusReg;
  reg [1:0]             snoopBusReg;

  output hit;
  output miss;
  output read;
  output write;

  // Establish wires/registers for use by the module
  reg[tagBits - 1:0]        addressTag;   // Current operation's tag from address
  reg[byteSelectBits - 1:0] byteSelect;   // Current byte select value
  reg[lineSize - 1:0]       cacheData;    // Data from the cache line being operated on
  reg[tagBits - 1:0]        cacheTag;     // Tag from the cache line being operated on
  reg                       hitFlag;      // Stores whether a hit has occurred or not
  reg                       readFlag;     // Stores whether we are doing a read or a write operation
  reg[indexBits - 1:0]      index;        // Currently selected set
  reg[$clog2(ways) - 1:0]   selectedWay;  // Current operation's selected way according to LRU
  
  wire[ways - 1:0]          COMPARATOR_OUT;       
  wire[lineSize - 1:0]      MUX_OUT;

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

  // Generate parameter "ways" amount of comparators
  genvar i;
  generate
  for (i = 0; i < ways; i = i + 1) begin
    Comparator #(ways) comparator(addressTag, Storage[i][L1Bus[byteSelectBits + indexBits - 1:0]].cacheTag, COMPARATOR_OUT[i]);
  end
  endgenerate

  // Instantiate our encoder for n ways
  Encoder #(ways) encoder(COMPARATOR_OUT, ENCODER_OUT);

  // Wire up the cache data lines to the bus for the multiplexor input
  case (ways)
    8: Multiplexor #(ways)  multiplexor(.select(ENCODER_OUT), .in0(Storage[0][L1Bus[byteSelectBits + indexBits - 1:0]].mesi),
      .in1(Storage[1][L1Bus[byteSelectBits + indexBits - 1:0]].mesi),
      .in2(Storage[2][L1Bus[byteSelectBits + indexBits - 1:0]].mesi),
      .in3(Storage[3][L1Bus[byteSelectBits + indexBits - 1:0]].mesi),
      .in4(Storage[4][L1Bus[byteSelectBits + indexBits - 1:0]].mesi),
      .in5(Storage[5][L1Bus[byteSelectBits + indexBits - 1:0]].mesi),
      .in6(Storage[6][L1Bus[byteSelectBits + indexBits - 1:0]].mesi),
      .in7(Storage[7][L1Bus[byteSelectBits + indexBits - 1:0]].mesi),
      .out(MUX_OUT));
  endcase

  // Assign the statistics outputs
  assign hit = hitFlag;
  assign miss = ~hit;
  assign read = readFlag;
  assign write = ~readFlag;

  // Assign buffers to the appropriate bus
  //assign L1Bus = L1BusReg;
  //assign L1OperationBus = L1OperationBusReg;
  //assign sharedBus = sharedBusReg;
  //assign sharedOperationBus = sharedOperationBusReg;

  //assign cacheData = MUX_OUT;

  // Performs necessary tasks/functions depending on whether there is a read or right to the cache
  always@(L1Bus, L1OperationBus, sharedBus, sharedOperationBus) begin

    // Command 0
    if (L1OperationBus == "DR") begin
      // Update the cache
      addressTag = L1Bus[addressSize - 1:byteSelectBits + indexBits];
      byteSelect = L1Bus[byteSelectBits - 1:0];
      index = L1Bus[byteSelectBits + indexBits - 1:byteSelectBits];

      CheckForHit;
      ReadL2Cache;
      UpdateLRU;
      if (display == 1)
        DisplayState(L1OperationBus);
    end

    // Command 1
    else if (L1OperationBus == "DW") begin
      // Update the cache
      addressTag = L1Bus[addressSize - 1:byteSelectBits + indexBits];
      byteSelect = L1Bus[byteSelectBits - 1:0];
      index = L1Bus[byteSelectBits + indexBits - 1:byteSelectBits];

      CheckForHit;
      WriteL2Cache;
      UpdateLRU;
      if (display == 1)
        DisplayState(L1OperationBus);
    end

    // Command 2
    else if (L1OperationBus == "IR") begin
      // Update the cache
      addressTag = L1Bus[addressSize - 1:byteSelectBits + indexBits];
      byteSelect = L1Bus[byteSelectBits - 1:0];
      index = L1Bus[byteSelectBits + indexBits - 1:byteSelectBits];

      CheckForHit;
      ReadL2Cache;
      UpdateLRU;
      if (display == 1)
        DisplayState(L1OperationBus);
    end

    // Command 3
    else if (sharedOperationBus == "I") begin
      // Update the cache
      addressTag = sharedBus[addressSize - 1:byteSelectBits + indexBits];
      byteSelect = sharedBus[byteSelectBits - 1:0];
      index = sharedBus[byteSelectBits + indexBits - 1:byteSelectBits];

      CheckForHit;
      ReadL2Cache;
      UpdateLRU;
      if (display == 1)
        DisplayState(sharedOperationBus);
    end

    // Command 4
    else if (sharedOperationBus == "R") begin
      // Update the cache
      addressTag = sharedBus[addressSize - 1:byteSelectBits + indexBits];
      byteSelect = sharedBus[byteSelectBits - 1:0];
      index = sharedBus[byteSelectBits + indexBits - 1:byteSelectBits];

      CheckForHit;
      ReadL2Cache;
      UpdateLRU;
      if (display == 1)
        DisplayState(sharedOperationBus);
    end

    // Command 5
    else if (sharedOperationBus == "W") begin
      // Update the cache
      addressTag = sharedBus[addressSize - 1:byteSelectBits + indexBits];
      byteSelect = sharedBus[byteSelectBits - 1:0];
      index = sharedBus[byteSelectBits + indexBits - 1:byteSelectBits];

      CheckForHit;
      ReadL2Cache;
      UpdateLRU;
      if (display == 1)
        DisplayState(sharedOperationBus);
    end

    // Command 6
    else if (sharedOperationBus == "M") begin
      // Update the cache
      addressTag = sharedBus[addressSize - 1:byteSelectBits + indexBits];
      byteSelect = sharedBus[byteSelectBits - 1:0];
      index = sharedBus[byteSelectBits + indexBits - 1:byteSelectBits];

      CheckForHit;
      ReadL2Cache;
      UpdateLRU;
      if (display == 1)
        DisplayState(sharedOperationBus);
    end

    // Command 8
    else if (L1OperationBus == "CL") begin
      ClearL2;
    end

    // Command 9
    else if (L1OperationBus == "PR") begin
      DisplayValid;
    end
  end

  task DisplayState (input[15:0] operation); begin
    automatic integer i;
    automatic string mesiStatus;

    $display("Command: %s", operation);
    $display("L1 Bus (Hex): %h", L1Bus[addressSize - 1:0]);
    $display("Shared Bus (Hex): %h", sharedBus[addressSize - 1:0]);
    $display("Address Tag (Hex): %h",addressTag);
    $display("Byte Select (Decimal): %d",byteSelect);
    $display("Index (Decimal): %d", index);

    if (hitFlag) begin
      $display("Cache hit from way: %d", selectedWay);
    end

    else if (~hitFlag) begin
      $display("Cache miss from way: %d", selectedWay);
    end

    for (i = 0; i < ways; i = i + 1) begin
      case (Storage[i][index].mesi)
        M: mesiStatus = "M";
        E: mesiStatus = "E";
        S: mesiStatus = "S";
        I: mesiStatus = "I";
      endcase

      $display("Way: %d\tLRU Value: %d\tMESI status: %s", i, Storage[i][index].lru, mesiStatus);
    end

    $display("\n");
  end
endtask

// Update the hit detection flag and set the selected way if necessary.
  task CheckForHit; begin
    automatic integer i;
    bit compare;
    hitFlag = 0;

    for (i = 0; i < ways; i = i + 1) begin
      hitFlag = hitFlag | (COMPARATOR_OUT[i] & ~Storage[i][index].mesi[3]);
    end
  end
endtask

task ReadL2Cache; begin
  readFlag = 1;

  if (hitFlag) begin
    case (Storage[selectedWay][index].mesi)
      M: begin
        cacheData = Storage[selectedWay][index].mesi; // We just want MESI bits, not the actual data.

        if (L1OperationBus == "DR") begin
          L1BusReg = "L1DR";
        end

        else if (L1OperationBus == "IR") begin
          L1BusReg = "L1IR";
        end

        Storage[selectedWay][index].mesi = M;
      end

      E: begin
        cacheData = Storage[selectedWay][index].mesi; // We just want MESI bits, not the actual data.

        if (L1OperationBus == "DR") begin
          L1BusReg = "L1DR";
        end

        else if (L1OperationBus == "IR") begin
          L1BusReg = "L1IR";
        end

        Storage[selectedWay][index].mesi = E;
      end

      S: begin
        cacheData = Storage[selectedWay][index].mesi; // We just want MESI bits, not the actual data.

        if (L1OperationBus == "DR") begin
          L1BusReg = "L1DR";
        end

        else if (L1OperationBus == "IR") begin
          L1BusReg = "L1IR";
        end

        Storage[selectedWay][index].mesi = S;
      end

      I: begin
        // Read from shared bus; if miss then RFO from shared bus
          sharedBusReg <= L1Bus;
          sharedOperationBusReg <= "R";

          // If snoop gives back HIT or HITM
          if (snoopBus == 2'b01 || snoopBus == 2'b10) begin

            QueryLRU;
            Storage[selectedWay][index].cacheTag = addressTag;
            Storage[selectedWay][index].cacheData = S;
            Storage[selectedWay][index].mesi = S;

            if (L1OperationBus == "DR") begin
              L1BusReg = "L1DR";
            end

            else if (L1OperationBus == "IR") begin
              L1BusReg = "L1IR";
            end

          end

          // Snoop gives back MISS
          else if (snoopBus == 2'b00) begin
            sharedBusReg <= L1Bus;
            sharedOperationBusReg <= "M";

            QueryLRU;
            Storage[selectedWay][index].cacheTag = addressTag;
            Storage[selectedWay][index].cacheData = E;
            Storage[selectedWay][index].mesi = E;

            if (L1OperationBus == "DR") begin
              L1BusReg = "L1DR";
            end

            else if (L1OperationBus == "IR") begin
              L1BusReg = "L1IR";
            end

          end
        end
      endcase
    end

    else if (!hitFlag) begin
      // Do get snoop, if nothing comes back:
        sharedBusReg <= L1Bus;
        sharedOperationBusReg <= "R";

        // If snoop gives back HIT or HITM
        if (snoopBus == 2'b01 || snoopBus == 2'b10) begin

          QueryLRU;
          Storage[selectedWay][index].cacheTag = addressTag;
          Storage[selectedWay][index].cacheData = S;
          Storage[selectedWay][index].mesi = S;
          L1BusReg = "DR";
        end

        // Snoop gives back MISS
        else if (snoopBus == 2'b00) begin
          sharedBusReg <= L1Bus;
          sharedOperationBusReg <= "M";

          QueryLRU;
          Storage[selectedWay][index].cacheTag = addressTag;
          Storage[selectedWay][index].cacheData = E;
          Storage[selectedWay][index].mesi = E;
          L1BusReg = "DR";
        end
      end
    end
  endtask

  task WriteL2Cache; begin
    readFlag = 0;

    if (hitFlag) begin
      case(Storage[selectedWay][index].mesi)
        M: begin
          // Write to Cache
          Storage[selectedWay][index].cacheData = M;
          Storage[selectedWay][index].mesi = M;
        end

        E: begin
          // Send invalidate
          sharedBusReg <= L1Bus;
          sharedOperationBusReg <= "I";
          Storage[selectedWay][index].cacheData = M;
          Storage[selectedWay][index].mesi = M;
        end

        S: begin
          // Send invalidate
          sharedBusReg <= L1Bus;
          sharedOperationBusReg <= "I";
          Storage[selectedWay][index].cacheData = M;
          Storage[selectedWay][index].mesi = M;
        end

        I: begin
          sharedBusReg <= L1Bus;
          sharedOperationBusReg <= "R";

          case (snoopBus)
            2'b01: begin // HIT
            Storage[selectedWay][index].cacheData = M;
            Storage[selectedWay][index].mesi = M;
          end

          2'b10: begin // HITM
          sharedBusReg <= L1Bus;
          sharedOperationBusReg <= "M";
          Storage[selectedWay][index].cacheData = M;
          Storage[selectedWay][index].mesi = M;
        end

        2'b00: begin // MISS
        Storage[selectedWay][index].cacheData = M;
        Storage[selectedWay][index].mesi = M;
      end
    endcase
  end
endcase
    end

    else if (!hitFlag) begin
      sharedBusReg <= L1Bus;
      sharedOperationBusReg <= "R";

      case (snoopBus)
        2'b01: begin // HIT
        Storage[selectedWay][index].cacheData = M;
        Storage[selectedWay][index].mesi = M;
      end

      2'b10: begin // HITM
      sharedBusReg <= L1Bus;
      sharedOperationBusReg <= "M";
      Storage[selectedWay][index].cacheData = M;
      Storage[selectedWay][index].mesi = M;
    end

    2'b00: begin // MISS
    Storage[selectedWay][index].cacheData = M;
    Storage[selectedWay][index].mesi = M;
  end
endcase
  end
end
  endtask

  task SnoopedInvalidateCommand; begin

    if (hitFlag) begin
      case(Storage[selectedWay][index].mesi)
        M: begin
          snoopBusReg = 2'b10;
          sharedBusReg = Storage[selectedWay][index].cacheData;
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

    else if (~hitFlag) begin  // MISS
      // Do nothing
    end
  end
endtask

task SnoopedReadRequest; begin

  if (hitFlag) begin
    case(Storage[selectedWay][index].mesi)
      M: begin
        snoopBusReg = 2'b10;
        sharedBusReg = Storage[selectedWay][index].cacheData;
        Storage[selectedWay][index].mesi = S;
      end

      E: begin
        snoopBusReg = 2'b01;
        sharedBusReg = Storage[selectedWay][index].cacheData;
        Storage[selectedWay][index].mesi = S;
      end

      S: begin
        snoopBusReg = 2'b01;
        sharedBusReg = Storage[selectedWay][index].cacheData;
        Storage[selectedWay][index].mesi = S;
      end

      I: begin
        snoopBusReg = 2'b00;
      end
    endcase
  end

  else if (~hitFlag) begin  // MISS
    // Do nothing
  end
end
  endtask

  task SnoopedWriteRequest; begin
    if (hitFlag) begin
      case (Storage[selectedWay][index].mesi)
        M: begin
          snoopBusReg = 2'b10;
          sharedBusReg = Storage[selectedWay][index].cacheData;
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
      // Do nothing
    end
  end
endtask

// Snooped read with intent to modify
task SnoopedRFO ();
  if(hitFlag) begin
    case(Storage[selectedWay][index].mesi)
      M: begin
        snoopBusReg <= 2'b10;
        sharedBusReg <= Storage[selectedWay][index].cacheData;
        Storage[selectedWay][index].mesi = I;
        Storage[selectedWay][index].lru = 3;
      end
      E: begin
        snoopBusReg <= 2'b01;
        sharedBusReg <= Storage[selectedWay][index].cacheData;
        Storage[selectedWay][index].mesi = I;
        Storage[selectedWay][index].lru = 3;
      end
      S: begin
        snoopBusReg <= 2'b01;
        Storage[selectedWay][index].mesi = I;
        Storage[selectedWay][index].lru = 3;
      end
      I: begin // Do nothing
    end
  endcase
end
    endtask

    // Clear cache & reset all states
    task ClearL2 ();
      automatic integer i,j;
      automatic integer sets = 2**indexBits;

      for (i = 0; i < ways; i = i + 1) begin
        for (j = 0; j < sets; j = j + 1) begin
          Storage[i][j].mesi = I;
          Storage[i][j].lru = 0;
        end
      end
    endtask

    // Print contents and state of each valid
    task DisplayValid ();
      automatic integer i,j;
      automatic integer sets = 2**indexBits;

      for (i = 0; i < ways; i = i + 1) begin
        for (j = 0; j < sets; j = j + 1) begin
          if(Storage[i][j].mesi != I);
          $display("Way: %d \t Index: %h \t MESI: %b \t LRU: %d", i, j, Storage[i][j].mesi, Storage[i][j].lru);
      end
    end
  endtask

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

task UpdateLRU; begin
  automatic integer i;

  // Save the selected way's LRU value
  automatic reg[2:0] selectedLRU = Storage[selectedWay][index].lru;

  for (i = 0; i < ways; i = i + 1) begin
    if (Storage[i][index].lru <= selectedLRU) begin
      Storage[i][index].lru = Storage[i][index].lru + 1;
    end
  end

  // Finally set the selected way to the most recently used
  Storage[selectedWay][index].lru = 0;
end
  endtask
  endmodule
