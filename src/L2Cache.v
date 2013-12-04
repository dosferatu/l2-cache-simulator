module L2Cache(command, address, snoopBus, sharedBus);
input command;
input address;
output snoopBus;
output sharedBus;

parameter ways = 8;
parameter dataBits = 9;
parameter indexBits = 14;
parameter tagBits = 10;

initial
begin
  // Instantiate n ways according to defined associativity
  genvar i;
  generate
  for (i = 0; i < ways; i = i + 1)
  begin
    //Way #(dataBits, indexBits, tagBits)  way();
  endgenerate

  // Wire up the cache output to the generated ways
  //HitDetection #(ways, dataBits, indexBits, tagBits) cacheOutput();
end
end module
