module cache_to_pmem
(
input logic clk,
input logic load,
input logic [255:0] datain,
output logic [255:0] dataout
);

logic [255:0] _pmem_data;

assign dataout = _pmem_data;

always_ff @(posedge clk) begin
	if (load) begin
		_pmem_data <= datain;
	end
end

endmodule 
