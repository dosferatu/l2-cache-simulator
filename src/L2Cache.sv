//**************************************************
// L2 Cache module
//
//**************************************************

`include "Comparator.sv"
`include "Encoder.sv"
`include "Multiplexor.sv"

module L2Cache(L1Bus, L1OperationBus, sharedBus, sharedOperationBus, snoopBus, hit, miss, read, write);
  // Establish parameters that can be used for dynamic sizing of cache
  parameter byteSelect  = 6;    // Number of byte select bits according to line size
  parameter indexBits   = 14;   // Number of bits from the address used for indexing to a set in way
  parameter lineSize    = 512;  // Size of the line of data in a set and used for shared bus size
  parameter L1BusSize   = 256;  // Size of Bus to communicate with the L1
  parameter tagBits     = 12;   // Number of bits from the address used for tag for validating index
  parameter ways        = 8;    // Number of ways for set associativity
  parameter R           = "R";   // Read operation
  parameter W           = "W";   // Write operation
  parameter M           = "M";   // Modify operation
  parameter I           = "I";   // Invalidate operation

  // Declare inputs and outputs
  inout logic[L1BusSize - 1:0] L1Bus;               // Bus used for communicating with L1
  inout logic[15:0]            L1OperationBus;      // Bus used for communicating with L1
  inout logic[lineSize - 1:0]  sharedBus;           // Bus used to designate read/write/modify/invalidate
  inout logic[7:0]             sharedOperationBus;  // Bus used to designate read/write/modify/invalidate
  inout logic[1:0]             snoopBus;            // Bus for getting/putting snoops

  output hit;
  output miss;
  output read;
  output write;

  // Establish wires/registers for use by the module
  reg[tagBits - 1:0]        addressTag;   // Current operation's tag from address
  reg[indexBits - 1:0]      index;        // Current operation's index from address
  reg[$clog2(ways) - 1:0]   selectedWay;  // Current operation's selected way according to LRU
  reg[lineSize - 1:0]       data;         // This will be used for holding data (in this case MESI bits) from cache to give it to
                                          //  output the necessary output for according the MESI protocol and the operation command
                                          //  received from the bus
  
  wire[lineSize - 1:0]        CACHE_DATA;           // Current operation's data (MESI bits) according to cache walk
  wire[$clog2(ways) - 1:0]    COMPARATOR_OUT;       
  wire[$clog2(ways) - 1:0]    VALID_OUT;            // Will hold all ways' MESI bit 0's pulled from cache storage

  reg hit;  // Stores whether a hit has occurred or not
  wire HIT;

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

    for (i = 0; i < ways; i = i + 1) begin
      for (j = 0; j < sets; j = j + 1) begin
        Storage[i][j].cacheTag = 0;
        Storage[i][j].cacheData = 0;
        Storage[i][j].mesi = 4'b0001;
        Storage[i][j].lru = 0;
      end
    end
  end

  // Loop through the set array at row[index]
  // Set the way to the least recently used column
  task QueryLRU; begin
    automatic integer LRUvalue = 0;
    automatic bit[indexBits - 1:0] Index;
    automatic integer i;

    // Assign unpacked index input to our word using
    // the streaming operator
    {>>{Index}} = index;

    // Loop through each way to find which way is LRU
    //  i is used to keep track of the current way during the loop
    for (i = 0;i < ways; i = i + 1) begin
      if (Storage[i][Index].lru > LRUvalue) begin
        LRUvalue = Storage[i][Index].lru;
        selectedWay = i;
      end
    end
  end
  endtask

  task UpdateLRU; begin
    automatic bit[indexBits - 1:0] index = L1Bus[byteSelect + indexBits - 1:byteSelect];
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

  // Generate parameter "ways" amount of comparators
  genvar i;
  generate
  for (i = 0; i < ways; i = i + 1) begin
    Comparator #(ways) comparator(addressTag, Storage[i][L1Bus[byteSelect + indexBits - 1:0]].cacheTag, COMPARATOR_OUT[i]);
  end
  endgenerate

  // Instantiate our encoder for n ways
  Encoder #(ways) encoder(COMPARATOR_OUT, ENCODER_OUT);

  // Wire up the cache data lines to the bus for the multiplexor input
  case (ways)
    8: Multiplexor #(lineSize, ways)  multiplexor(ENCODER_OUT, Storage[0][L1Bus[byteSelect + indexBits - 1:0]].mesi,
      Storage[1][L1Bus[byteSelect + indexBits - 1:0]].mesi,
      Storage[2][L1Bus[byteSelect + indexBits - 1:0]].mesi,
      Storage[3][L1Bus[byteSelect + indexBits - 1:0]].mesi,
      Storage[4][L1Bus[byteSelect + indexBits - 1:0]].mesi,
      Storage[5][L1Bus[byteSelect + indexBits - 1:0]].mesi,
      Storage[6][L1Bus[byteSelect + indexBits - 1:0]].mesi,
      Storage[7][L1Bus[byteSelect + indexBits - 1:0]].mesi,
      MUX_OUT);
  endcase

  // Wire up hit detection
  for (i = 0; i < ways; i = i + 1) begin
    assign HIT = HIT | (COMPARATOR_OUT[i] & Storage[i][L1Bus[byteSelect + indexBits - 1:byteSelect]].mesi[0]);
  end

  // Store the result in a reg for us to access
  assign hit = HIT;

  // Performs necessary tasks/functions depending on whether there is a read or right to the cache
  always@(L1Bus, L1OperationBus, sharedBus, sharedOperationBus) begin
    if (L1OperationBus == "DR") begin
      // Read cache

      // Hit
      if (hit)
        $display("There was a cache hit!");
      else
        $display("There was a cache miss!");
      // Miss
    end

    else if (L1OperationBus == "DW") begin
    end

    else if (L1OperationBus == "IR") begin
    end

    else if (sharedOperationBus == "R") begin
    end

    else if (sharedOperationBus == "W") begin
    end

    else if (sharedOperationBus == "M") begin
    end

    else if (sharedOperationBus == "I") begin
    end
  end
endmodule
