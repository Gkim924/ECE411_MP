module cache_control (
input clk,
input logic mem_read,
input logic mem_write,
input logic hit_0,
input logic hit_1,
input logic miss,
input logic dirty,
input logic pmem_resp,
output logic mem_resp,
output logic load_valid,
output logic load_tag,
output logic load_dirty,
output logic load_lru,
output logic load_data,
output logic load_mode,
input logic LRU,
output logic way_sel,
output logic cache_array_read,
output logic dirty_types,
output logic pmem_read,
output logic pmem_write,
output logic pmem_addr_mux_sel,
output logic load_transfer
);

enum int unsigned {
	/* List of States */
	IDLE,
	HIT,
	STORE_ITERMED,
	MISS_STORE,
	MISS_LOAD
} State, Next_State;


/**********States output Here*********/
always_comb begin
	
	//default output signals assignment
	mem_resp = 1'b0;
	load_valid = 1'b0;
	load_tag = 1'b0;
	load_dirty = 1'b0;
	load_lru = 1'b0;
	load_data = 1'b0;
	load_mode = 1'b0;
	cache_array_read = 1'b0;
	dirty_types = 1'b0;
	pmem_read = 1'b0;
	pmem_write = 1'b0;
	pmem_addr_mux_sel = 1'b0;
	way_sel = 1'b0;
	load_transfer = 1'b0;
	
	unique case (State)
	
		
		IDLE: if (mem_read | mem_write) cache_array_read = 1'b1;
		
		
		HIT:  begin
			if (miss) begin
				way_sel = LRU;
				if (dirty) begin
					dirty_types = 1'b0;
					pmem_addr_mux_sel = 1'b1;
					load_dirty = 1'b1;
				end
				else begin
					load_valid = 1'b1;
				end 
				
			end
			else begin
				way_sel = hit_1;
				if (mem_read) begin
					mem_resp = 1'b1;
					load_lru = 1'b1;
				end
				else begin
					mem_resp = 1'b1;
					dirty_types = 1'b1;
					load_dirty = 1'b1;
					load_lru = 1'b1;
					load_data = 1'b1;
					load_mode = 1'b0;
				end
			end
		end
		
		
		STORE_ITERMED: begin
			way_sel = LRU;
			pmem_addr_mux_sel = 1'b1;
			load_transfer = 1'b1;
		end

		
		MISS_STORE:  begin
			way_sel = LRU;
			pmem_write = 1'b1;
			pmem_addr_mux_sel = 1'b1;
		end
		
		
		MISS_LOAD:  begin
			way_sel = LRU;
			pmem_read = 1'b1;
			pmem_addr_mux_sel = 1'b0;
			load_mode = 1'b1;

			if (pmem_resp) begin
				load_data = 1'b1;
			   load_tag = 1'b1;
				pmem_read = 1'b1;
				pmem_addr_mux_sel = 1'b0;
				load_mode = 1'b1;
			end
			
		end
	
	
	
	endcase


end


/**********Next States logic Here*********/
always_comb begin

	unique case (State)
	
		IDLE : begin  
			if (mem_read | mem_write) Next_State = HIT;
			else Next_State = IDLE;
		end
		
		
		HIT :   begin
			if (miss) begin
				if (dirty) Next_State = STORE_ITERMED;
				else Next_State = MISS_LOAD;
			end
			else Next_State = IDLE;
			
		end
		
		STORE_ITERMED : begin
			Next_State = MISS_STORE;
		end
		
		MISS_STORE : begin
			if (pmem_resp) Next_State = MISS_LOAD;
			else Next_State = MISS_STORE;
		end
		
		MISS_LOAD : begin
			if (pmem_resp) Next_State = IDLE;
			else Next_State = MISS_LOAD;
		end
	
	
	endcase

end


/**********Transfer to next state********/
always_ff @(posedge clk) begin
	
	State <= Next_State;
	
end



endmodule : cache_control
