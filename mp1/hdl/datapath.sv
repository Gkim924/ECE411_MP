`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import rv32i_types::*;

module datapath
(
	 input clk,
	 //signals from control
	 input load_pc,
	 input load_ir,
	 input load_regfile,
	 input load_mar,
	 input load_mdr,
	 input load_data_out,
	 input pcmux::pcmux_sel_t pcmux_sel,
	 input branch_funct3_t cmpop,
	 input alumux::alumux1_sel_t alumux1_sel,
	 input alumux::alumux2_sel_t alumux2_sel,
	 input regfilemux::regfilemux_sel_t regfilemux_sel,
	 input marmux::marmux_sel_t marmux_sel,
	 input cmpmux::cmpmux_sel_t cmpmux_sel,
	 input alu_ops aluop,
	 
	 //signals from memory
	 input rv32i_word mem_rdata,
	 
	 //signals to control
	 output rv32i_opcode opcode,
	 output logic [2:0] funct3,
	 output logic [6:0] funct7,
	 output logic br_en,
	 output logic [4:0] rs1,
	 output logic [4:0] rs2,
	 
	 //signals to memory
	 output rv32i_word mem_wdata, 
	 output rv32i_word mem_address // signal used by RVFI Monitor
);

/******************* Signals Needed for RVFI Monitor *************************/




//from IR
rv32i_reg internal_rs1;
rv32i_reg internal_rs2;
rv32i_reg rd;

assign rs1 = internal_rs1;
assign rs2 = internal_rs2;

rv32i_word rs1_out;
rv32i_word rs2_out;
rv32i_word i_imm;
rv32i_word u_imm;
rv32i_word b_imm;
rv32i_word s_imm;
rv32i_word j_imm;

//rv321_opcode opcode;

//logic[2:0] funct3;
//logic[6:0] funct7;

//from pcmux
rv32i_word pcmux_out;

//from alumux1
rv32i_word alumux1_out;

//from alumux2
rv32i_word alumux2_out;

//from regfilemux
rv32i_word regfilemux_out;

//from marmux
rv32i_word marmux_out;

//from cmpmux
rv32i_word cmpmux_out;

//from ALU
rv32i_word alu_out;

//from PC
rv32i_word pc_out;

//from MDR
rv32i_word mdrreg_out;

//from MAR
//rv32i_word mem_address;

//from CMP
//logic br_en;



/*****************************************************************************/

//*Take care of unaligned cases
rv32i_word mdr_after_shift;
assign mdr_after_shift = mdrreg_out >> ('d8 * mem_address[1:0]);

rv32i_word mem_wdata_after_shift;
assign mem_wdata_after_shift = rs2_out << ('d8 * alu_out[1:0]);

/***************************** Registers *************************************/
// Keep Instruction register named `IR` for RVFI Monitor
ir IR(
	 .clk    (clk),
	 .load   (load_ir),
	 .in	   (mdrreg_out),
	 .funct3 (funct3),
	 .funct7 (funct7),
	 .opcode (opcode),
	 .i_imm  (i_imm),
	 .s_imm  (s_imm),
	 .u_imm	(u_imm),
	 .b_imm	(b_imm),
	 .j_imm  (j_imm),
	 .rs1		(internal_rs1),
	 .rs2		(internal_rs2),
	 .rd		(rd)
);

register MDR(
	.clk  (clk),
	.load (load_mdr),
   .in   (mem_rdata),
   .out  (mdrreg_out)
);

register MAR(
	.clk 	(clk),
	.load (load_mar),
	.in	(marmux_out),
	.out 	(mem_address)
);

register MEM_PENDER(
	.clk  (clk),
	.load (load_data_out),
	.in  	(mem_wdata_after_shift),
	.out 	(mem_wdata)
);

pc_register PC_REG(
	.clk  (clk),
	.load (load_pc),
	.in   (pcmux_out),
	.out  (pc_out)
);

regfile regfile(
	.clk   (clk),
	.load  (load_regfile),
	.in	 (regfilemux_out),
	.src_a (internal_rs1),
	.src_b (internal_rs2),
	.dest  (rd),
	.reg_a (rs1_out),
	.reg_b (rs2_out)
);




/*****************************************************************************/

/******************************* ALU and CMP *********************************/
alu ALU(
	.aluop   (aluop),
	.a       (alumux1_out),
	.b       (alumux2_out),
	.f 		(alu_out)
);

cmp CMP(
	.src_a (rs1_out),
	.src_b (cmpmux_out),
	.cmpop (cmpop),
	.br_en (br_en)
);


/*****************************************************************************/

/******************************** Muxes **************************************/
always_comb begin : MUXES
    // We provide one (incomplete) example of a mux instantiated using
    // a case statement.  Using enumerated types rather than bit vectors
    // provides compile time type safety.  Defensive programming is extremely
    // useful in SystemVerilog.  In this case, we actually use 
    // Offensive programming --- making simulation halt with a fatal message
    // warning when an unexpected mux select value occurs
    unique case (pcmux_sel)
		  pcmux::pc_plus4: pcmux_out = pc_out + 4;
		  // etc.
		  pcmux::alu_out: pcmux_out = alu_out;
		  pcmux::alu_mod2: pcmux_out = (alu_out & 32'hFFFFFFFE);
		  default: `BAD_MUX_SEL;
	 endcase
	 
	 unique case (marmux_sel)
		  marmux::pc_out: marmux_out = pc_out;
		  marmux::alu_out: marmux_out = alu_out;
		  default: `BAD_MUX_SEL;
	 endcase
	 
	 unique case (cmpmux_sel)
		  cmpmux::rs2_out: cmpmux_out = rs2_out;
		  cmpmux::i_imm: cmpmux_out = i_imm;
		  default: `BAD_MUX_SEL;
	 endcase
	 
	 unique case (alumux1_sel)
		  alumux::rs1_out: alumux1_out = rs1_out;
		  alumux::pc_out: alumux1_out = pc_out;
		  default: `BAD_MUX_SEL;
	 endcase
	 
	 unique case (alumux2_sel)
		  alumux::i_imm: alumux2_out = i_imm;
		  alumux::u_imm: alumux2_out = u_imm;
		  alumux::b_imm: alumux2_out = b_imm;
		  alumux::s_imm: alumux2_out = s_imm;
		  alumux::j_imm: alumux2_out = j_imm;
		  alumux::rs2_out: alumux2_out = rs2_out;
		  default: `BAD_MUX_SEL;
	 endcase
	 
	 unique case (regfilemux_sel)
		  regfilemux::alu_out: regfilemux_out = alu_out;
		  regfilemux::br_en: regfilemux_out = {31'b0, br_en};
		  regfilemux::u_imm: regfilemux_out = u_imm;
		  regfilemux::lw: regfilemux_out = mdrreg_out;
		  regfilemux::pc_plus4: regfilemux_out = pc_out + 4;
		  regfilemux::lb: regfilemux_out = 32'(signed'(mdr_after_shift[7:0]));
		  regfilemux::lbu: regfilemux_out = {24'b0, mdr_after_shift[7:0]};
		  regfilemux::lh: regfilemux_out = 32'(signed'(mdr_after_shift[15:0]));
		  regfilemux::lhu: regfilemux_out = {16'b0, mdr_after_shift[15:0]};
	 endcase
end
/*****************************************************************************/
endmodule : datapath
