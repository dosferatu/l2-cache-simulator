//**************************************************
// CACHE DATA STRUCTURE (WAY)
//
//**************************************************

module Way(index. tag, data, valid, write);

parameter indexBits = 14;
parameter lineSize = 512;
parameter tagBits = 14;

input index;
input write;
inout[lineSize - 1:0] data;
inout[tagBits - 1:0] tag;
output valid;

reg[lineSize - 1:0] cacheData;
reg[tagBits - 1:0] cacheTag;
reg valid;

always @(write)
begin
	if (write)
	begin
		assign cacheData = data;
		assign cacheTag = tag;
		valid[index] = 1;
		else if (!write)
		begin
			assign data = cacheData;
			assign tag = cacheTag;
		end
	end
end
endmodule
