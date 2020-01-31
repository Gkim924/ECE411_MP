module cache_datapath #(
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
	output logic [255:0] mem_rdata256,
	input logic [255:0] mem_wdata256,
	input logic [31:0] mem_byte_enable256,
	input logic [255:0] pmem_rdata,
	output logic [255:0] pmem_wdata_datapath,
	output logic [31:0] pmem_address,
	input logic [31:0] addr_from_cpu,
	input logic load_valid,
	input logic load_tag,
	input logic load_dirty,
	input logic load_lru,
	input logic load_data,
	input logic load_mode,
	input logic cache_array_read,
	output logic hit_0,
   output logic hit_1,
	output logic dirty,
	input logic dirty_types,
	input logic pmem_addr_mux_sel,
	output logic LRU,
	input logic way_sel
);



/************internal signals**************/
logic [23:0] tag_in;
logic [2:0] index;

logic valid_0;
logic valid_1;
logic [23:0] tag_0;
logic [23:0] tag_1;
logic [23:0] tag_out;
logic dirty_0;
logic dirty_1;

logic [255:0] data_array_in;
logic [255:0] data_0;
logic [255:0] data_1;

logic [31:0] enable_signal0;
logic [31:0] enable_signal1;

logic [1:0] load_valid_combined;
logic [1:0] load_tag_combined;
logic [1:0] load_dirty_combined;
logic [63:0] write_en_combined;

/************logic on wires****************/
assign tag_in = mem_address[31:8];
assign index = mem_address[7:5];

assign load_valid_combined = {load_valid && way_sel, load_valid && (~way_sel)};
assign load_tag_combined = {load_tag && way_sel, load_tag && (~way_sel)};
assign load_dirty_combined = {load_dirty && way_sel, load_dirty && (~way_sel)};
assign write_en_combined = {enable_signal1, enable_signal0};


assign hit_0 = valid_0 && (tag_0 == tag_in);
assign hit_1 = valid_1 && (tag_1 == tag_in);
/***********modules declared here**********/
array valid_array[1:0]  //valid_array_0
(
.clk,
.read(cache_array_read),
.load(load_valid_combined),
.index,
.datain(1'b1),
.dataout({valid_1, valid_0})
);



array #(.width(24)) tag[1:0]   //tag_array_0
(
.clk,
.read(cache_array_read),
.load(load_tag_combined),
.index,
.datain(tag_in),
.dataout({tag_1, tag_0})
);




array dirty_array[1:0]  //dirty_array_0
(
.clk,
.read(cache_array_read),
.load(load_dirty_combined),
.index,
.datain(dirty_types),
.dataout({dirty_1, dirty_0})
);

array lru_array
(
.clk,
.read(1'b1),
.load(load_lru),
.index,
.datain(~way_sel),
.dataout(LRU)
);



data_array line[1:0]   //data_array_0
(
.clk,
.read(cache_array_read),
.write_en(write_en_combined),
.index,
.datain(data_array_in),
.dataout({data_1, data_0})
);






/***************MUXES**********************/
always_comb begin

	case (way_sel)
		
		1'b0 :  begin

			if (load_data) begin
				
				case (load_mode)
					1'b0: enable_signal0 = mem_byte_enable256;
					1'b1: enable_signal0 = 32'hffffffff;	
				endcase
				
			end
			else enable_signal0 = 32'b0;
		
			enable_signal1 = 32'b0;
		end
		
		1'b1 : begin

			if (load_data) begin
				
				case (load_mode)
					1'b0: enable_signal1 = mem_byte_enable256;
					1'b1: enable_signal1 = 32'hffffffff;
				endcase
				
			end
			else enable_signal1 = 32'b0;
			
			enable_signal0 = 32'b0;
		end
		
		default : begin
			enable_signal0 = 32'b0;
			enable_signal1 = 32'b0;
		end
		
	endcase

	
	case (load_mode)
		1'b1 : data_array_in = pmem_rdata;
		1'b0 : data_array_in = mem_wdata256;
	endcase
	
	
	case (way_sel)
		1'b0 : begin
			tag_out = tag_0;
			dirty = dirty_0;
			mem_rdata256 = data_0;
			pmem_wdata_datapath = data_0;
		end
		1'b1 : begin
			tag_out = tag_1;
			dirty = dirty_1;
			mem_rdata256 = data_1;
			pmem_wdata_datapath = data_1;
		end
		
		default : begin
			tag_out = tag_0;
			dirty = dirty_0;
			mem_rdata256 = data_0;
			pmem_wdata_datapath = data_0;
		end
	endcase
	
	case (pmem_addr_mux_sel)	
		1'b0 : pmem_address = addr_from_cpu & {27'(signed'(1'b1)), 5'b0}; 
		1'b1 : pmem_address = {tag_out, index, 5'b0};
	endcase

end

/*****************************************/


endmodule : cache_datapath
