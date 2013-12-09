//**************************************************
// L2 Cache module
//
//**************************************************

module L2Cache(L1Bus, L1OperationBus, sharedBus, sharedOperationBus, snoopBus, hit, miss, read, write);
  // Establish parameters that can be used for dynamic sizing of cache
  parameter byteSelect  = 6;    // Number of byte select bits according to line size
  parameter addressSize = 32;   // Instruction size used by architecture
  parameter indexBits   = 14;   // Number of bits from the address used for indexing to a set in way
  parameter lineSize    = 512;  // Size of the line of data in a set and used for shared bus size
  parameter L1BusSize   = 256;  // Size of Bus to communicate with the L1
  parameter tagBits     = 12;   // Number of bits from the address used for tag for validating index
  parameter ways        = 8;    // Number of ways for set associativity
  parameter M           = 4'b0001;
  parameter E           = 4'b0010;
  parameter S           = 4'b0100;
  parameter I           = 4'b1000;

  // Declare inputs and outputs
  inout [L1BusSize - 1:0] L1Bus;               // Bus used for communicating with L1
  inout [15:0]            L1OperationBus;      // Bus used for communicating with L1
  inout [lineSize - 1:0]  sharedBus;           // Bus used to designate read/write/modify/invalidate
  inout [7:0]             sharedOperationBus;  // Bus used to designate read/write/modify/invalidate
  inout [1:0]             snoopBus;            // Bus for getting/putting snoops

  output hit;
  output miss;
  output read;
  output write;

  // Establish wires/registers for use by the module
  reg[tagBits - 1:0]        addressTag;   // Current operation's tag from address
  reg[lineSize - 1:0]       cacheData;
  reg                       hitFlag;      // Stores whether a hit has occurred or not
  reg[indexBits - 1:0]      index;        // Stores the current index specified in the address
  reg[$clog2(ways) - 1:0]   selectedWay;  // Current operation's selected way according to LRU
  
  wire[ways - 1:0]            COMPARATOR_OUT;       
  wire[$clog2(ways) - 1:0]    ENCODER_OUT;
  wire[lineSize - 1:0]        MUX_OUT;

  // Cache line structure
  typedef struct {
    bit[tagBits - 1:0] cacheTag;
    bit[lineSize - 1:0] cacheData;
    bit[3:0] mesi;
    bit[$clog2(ways) - 1:0] lru;
  } line;

  // Generate n ways using n structs x m sets
  line Storage[$clog2(ways) - 1:0][indexBits - 1:0];

  // Initialize the L2 cache storage to an empty and invalidated state
  initial begin
    automatic integer i,j;
    automatic integer sets = 2**indexBits;

    selectedWay = 0;

    for (i = 0; i < ways; i = i + 1) begin
      for (j = 0; j < sets; j = j + 1) begin
        Storage[i][j].cacheTag = 9;
        Storage[i][j].cacheData = 0;
        Storage[i][j].mesi = 4'b1000;
        Storage[i][j].lru = 0;
      end
    end

    //for (i = 0; i < sets; i = i + 1) begin
        //Storage[i].cacheTag = 9;
        //Storage[i].cacheData = 0;
        //Storage[i].mesi = 4'b1000;
        //Storage[i].lru = 0;
      //end
    //$display(Storage[7].cacheTag);
  end

  // Perform the necessary cache operations
  always@(L1Bus, L1OperationBus, sharedBus, sharedOperationBus) begin

    // Update the address tag, index, and byte select
    addressTag = L1Bus[addressSize - 1:byteSelect + indexBits];
    index = L1Bus[byteSelect + indexBits - 1:byteSelect];
    
    // Doesn't work if index > 7
    $display(Storage[selectedWay][index].cacheTag);

    // Does work
    // Storage[0][0].cacheTag = 333;
    // $display(Storage[0][0].cacheTag);
    // Storage[0][0].cacheTag = 888;
    // $display(Storage[0][0].cacheTag);

    // Command 0
    if (L1OperationBus == "DR") begin
      //DisplayState("DR");
      CheckForHit;
      ReadL2Cache;
      UpdateLRU;
    end

    // Command 1
    else if (L1OperationBus == "DW") begin
//      DisplayState("DW");
      CheckForHit;
      WriteL2Cache;
      UpdateLRU;
    end

    // Command 2
    else if (L1OperationBus == "IR") begin
//      DisplayState("IR");
      CheckForHit;
      ReadL2Cache;
      UpdateLRU;
    end

    else if (sharedOperationBus == "R") begin
      DisplayState("R");
    end

    else if (sharedOperationBus == "W") begin
      DisplayState("W");
    end

    else if (sharedOperationBus == "M") begin
      DisplayState("M");
    end

    else if (sharedOperationBus == "I") begin
      DisplayState("I");
    end
  end

  task DisplayState (input[15:0] operation); begin
    automatic integer i;

    $display("Command: %s", operation);
    $display("Index: %d",L1Bus[byteSelect + indexBits - 1:byteSelect]);
    $display("Address Tag: %h",addressTag);

    for (i = 0; i < ways; i = i + 1) begin
      $display("Cache tag for way %d: %h", i, Storage[i][index].cacheTag);
    end

    $display();
    $display();
  end
  endtask

  // Update the hit detection flag and set the selected way if necessary.
  task CheckForHit; begin
    automatic integer i;

    for (i = 0; i < ways; i = i + 1) begin
      if (addressTag & Storage[i][index].cacheTag) begin
        hitFlag = 1;
        selectedWay = i;
      end

      else begin
        hitFlag = 0;
      end
    end
  end
  endtask

  task ReadL2Cache; begin

    if (hitFlag) begin
      $display("There was a cache hit!");
      cacheData = Storage[selectedWay][index].mesi; // We just want MESI bits, not the actual data.

      //case (Storage[selectedWay][L1Bus[byteSelect + indexBits - 1:byteSelect]].mesi)
      //M: Write to the L1 bus
      //E: Write to the L1 bus
      //S: Write to the L1 bus
      //I: Read from the shared bus
      //if hit from shared bus: get data from shared bus, write to L2
        //storage, write to the L1 bus.
        //if miss from shared bus: RFO from shared bus, write to L2
          //storage, write to the L1 bus.
          //endcase
    end

    else if (!hitFlag) begin
      $display("There was a cache miss!");
      // Do stuff for a miss
      
      // Do get snoop, if nothing comes back:
      // Read from shared bus
      QueryLRU;
      Storage[selectedWay][index].cacheTag = addressTag;
      Storage[selectedWay][index].cacheData = 400;
      Storage[selectedWay][index].mesi = S;
    end
  end
  endtask

  task WriteL2Cache; begin
    //query the LRU
    //check if we have a hit on the tag
      //if not then we need to read from shared bus,
        //write to storage, write to L1 bus
      //if we do then write data to L1 bus
        //
        //if hit, write to storage
          //if miss, RFO from shared bus, write to storage
  end
  endtask

  // Loop through the set array at row[index]
  // Set the way to the least recently used column
  task QueryLRU; begin
    automatic integer LRUvalue = 0;
    automatic integer i;

    // Loop through each way to find which way is LRU
    //  i is used to keep track of the current way during the loop
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
