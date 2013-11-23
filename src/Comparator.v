//**************************************************
// Cache tag comparator:
// inputs: address tag, cache tag
// outputs: match
//**************************************************

module Comparator(
  addressTag[4:0],
  cacheTag[4:0],
  match
);
  input[4:0] addressTag;
  input[4:0] cacheTag;
  output match;

  reg match;
  wire[4:0] addressTag;
  wire[4:0] cacheTag;

  always @(addressTag or cacheTag)
  begin
    assign match = addressTag && cacheTag;
  end

end module
