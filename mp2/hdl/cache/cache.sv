module cache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
	input clk,
	input logic [31:0] mem_address,
	output logic [31:0] mem_rdata,
	input logic [31:0] mem_wdata,
	input logic mem_read,
	input logic mem_write,
	input logic [3:0] mem_byte_enable,
	output logic mem_resp,
	output logic [31:0] pmem_address,
	input logic [255:0] pmem_rdata,
	output logic [255:0] pmem_wdata,
	output logic pmem_read,
	output logic pmem_write,
	input logic pmem_resp
);

/********internal wires*************/

logic [31:0] mem_byte_enable256;
logic [255:0] mem_rdata256;
logic [255:0] mem_wdata256;

logic [255:0] pmem_wdata_datapath;

logic hit_0;
logic hit_1;
logic miss;
logic dirty;
logic load_valid;
logic load_tag;
logic load_dirty;
logic load_lru;
logic load_data;
logic load_mode;
logic way_sel;
logic cache_array_read;
logic dirty_types;
logic pmem_addr_mux_sel;
logic LRU;
logic load_transfer;

/********logic on wires*************/
assign miss = ~(hit_0 | hit_1);


/*******modules declared here*******/

cache_control control
(
.clk,
.mem_read,
.mem_write,
.hit_0,
.hit_1,
.miss,
.dirty,
.pmem_resp,
.mem_resp,
.load_valid,
.load_tag,
.load_dirty,
.load_lru,
.load_data,
.load_mode,
.LRU,
.way_sel,
.cache_array_read,
.dirty_types,
.pmem_read,
.pmem_write,
.pmem_addr_mux_sel,
.load_transfer
);


cache_datapath datapath
(
.clk,
.mem_address,
.mem_rdata256,
.mem_wdata256,
.mem_byte_enable256,
.pmem_rdata,
.pmem_wdata_datapath,
.pmem_address,
.addr_from_cpu(mem_address),
.load_valid,
.load_tag,
.load_dirty,
.load_lru,
.load_data,
.load_mode,
.cache_array_read,
.hit_0,
.hit_1,
.dirty,
.dirty_types,
.pmem_addr_mux_sel,
.LRU,
.way_sel
);


bus_adapter adapter
(
.mem_wdata256,
.mem_rdata256,
.mem_wdata,
.mem_rdata,
.mem_byte_enable,
.mem_byte_enable256,
.address(mem_address)
);

cache_to_pmem datatransfer
(
.clk,
.load(load_transfer),
.datain(pmem_wdata_datapath),
.dataout(pmem_wdata)
);

endmodule : cache
