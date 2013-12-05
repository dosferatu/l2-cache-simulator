//**************************************************
// L2 Cache module
//
//**************************************************

`include "DataStructureBlock.v"
`include "OutputBlock.v"

module L2Cache(command, address, snoopBus, sharedBus);
parameter indexBits = 14;
parameter lineSize = 512;
parameter tagBits = 12;
parameter ways = 8;

input command;
input[tagBits + indexBits - 1:0] address;
output snoopBus;
output sharedBus;

reg data[lineSize - 1:0];
reg read;

wire[tagBits - 1:0] CACHETAG;
wire[lineSize - 1:0] CACHEDATA;
wire[3:0] MESI;

/*
* The data structure block and output block need to be heavily scrutinized to
* verity that the proper inputs and outputs are present for any requirements
* our cache implementation will need including cache coherency protocol.
* Please change as desired or make note of any needed changes.
*/

// Instantiate the cache storage block
DataStructureBlock #(indexBits, lineSize, tagBits, ways) Cache(address[indexBits - 1:0], address[tagBits - 1:indexBits], CACHETAG, CACHEDATA, read);

// Instantiate the cache output block and wire it to the storage block
OutputBlock #(indexBits, lineSize, tagBits, ways) CacheOutput();
endmodule
