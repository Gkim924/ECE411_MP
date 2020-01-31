import rv32i_types::*;

module mp2
(
    input clk,
    input pmem_resp,
    input [255:0] pmem_rdata,
    output logic pmem_read,
    output logic pmem_write,
    output rv32i_word pmem_address,
    output [255:0] pmem_wdata
);

//signals between cache and cpu ************/
logic mem_resp;
logic mem_read;
logic mem_write;
logic [3:0] mem_byte_enable;
rv32i_word mem_address;
rv32i_word mem_rdata;
rv32i_word mem_wdata;
/**************************************/

// Keep cpu named `cpu` for RVFI Monitor
// Note: you have to rename your mp1 module to `cpu`
cpu cpu(.*);

// Keep cache named `cache` for RVFI Monitor
cache cache(.*);

endmodule : mp2
