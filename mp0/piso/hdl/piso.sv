
module piso_converter(
    input logic clk_i,
    input logic reset_n_i,

    // Parallel Side protocol
    input  logic [31:0] p_i,
    input  logic valid_i,
    input  logic [1:0] byte_en_i,
    output logic rdy_o,

    // Serial Logic
    output logic s_o,
    output logic valid_o,
    output logic last_o,
    input  logic ack_i,
    input  logic nack_i
);


//declare all internal logic here
logic [31:0] par_r;
logic [1:0] en_r;

enum logic [6:0] {
READY, 
SERIAL_1, 
SERIAL_2, 
SERIAL_3, 
SERIAL_4, 
SERIAL_5, 
SERIAL_6, 
SERIAL_7, 
SERIAL_8, 
SERIAL_9, 
SERIAL_10, 
SERIAL_11, 
SERIAL_12, 
SERIAL_13, 
SERIAL_14, 
SERIAL_15, 
SERIAL_16, 
SERIAL_17, 
SERIAL_18, 
SERIAL_19, 
SERIAL_20, 
SERIAL_21, 
SERIAL_22, 
SERIAL_23, 
SERIAL_24, 
SERIAL_25, 
SERIAL_26, 
SERIAL_27, 
SERIAL_28, 
SERIAL_29, 
SERIAL_30, 
SERIAL_31, 
SERIAL_32, 
SERIAL_33, 
SERIAL_34, 
SERIAL_35, 
SERIAL_36,  
WAIT_1, 
WAIT_2, 
WAIT_3, 
WAIT_4, 
WAIT_5, 
WAIT_6, 
WAIT_7, 
WAIT_8, 
DONE} State, NextState;



//********************** Non-blocking Assignment ***************


//parallel_load
always_ff @(posedge clk_i) begin
	if (~reset_n_i) begin
		par_r <= 32'b0;
		en_r <= 2'b0;
		State <= READY;
	end
	else if (reset_n_i && valid_i) begin
			par_r <= p_i;
			en_r <= byte_en_i;
			State <= SERIAL_1;
	end
	else begin
		State <= NextState;
	end
	
end




//state machine
always_ff @(posedge clk_i) begin

	last_o = 1'b0;
	valid_o <=1'b0;
	s_o <= 'bx;
	
	case (State)
		SERIAL_1: begin
			s_o <= par_r[0];
			valid_o <= 1'b1;
		end
		
		SERIAL_2: begin
			s_o <= par_r[1];
			valid_o <= 1'b1;
		end
		
		SERIAL_3: begin
			s_o <= par_r[2];
			valid_o <= 1'b1;
		end
		
		SERIAL_4: begin
			s_o <= par_r[3];
			valid_o <= 1'b1;
		end
		
		SERIAL_5: begin
			s_o <= par_r[4];
			valid_o <= 1'b1;
		end
		
		SERIAL_6: begin
			s_o <= par_r[5];
			valid_o <= 1'b1;
		end
		
		SERIAL_7: begin
			s_o <= par_r[6];
			valid_o <= 1'b1;
		end
		
		SERIAL_8: begin
			s_o <= par_r[7];
			valid_o <= 1'b1;
		end
		
		SERIAL_9: begin
			s_o <= (^par_r[7:0]);
			valid_o <= 1'b1;
		end
		
		SERIAL_10: begin
			s_o <= par_r[8];
			valid_o <= 1'b1;
		end
		
		SERIAL_11: begin
			s_o <= par_r[9];
			valid_o <= 1'b1;
		end
		
		SERIAL_12: begin
			s_o <= par_r[10];
			valid_o <= 1'b1;
		end
		
		SERIAL_13: begin
			s_o <= par_r[11];
			valid_o <= 1'b1;
		end
		
		SERIAL_14: begin
			s_o <= par_r[12];
			valid_o <= 1'b1;
		end
		
		SERIAL_15: begin
			s_o <= par_r[13];
			valid_o <= 1'b1;
		end
		
		SERIAL_16: begin
			s_o <= par_r[14];
			valid_o <= 1'b1;
		end
		
		SERIAL_17: begin
			s_o <= par_r[15];
			valid_o <= 1'b1;
		end
		
		SERIAL_18: begin
			s_o <= (^par_r[15:8]);
			valid_o <= 1'b1;
		end
		
		SERIAL_19: begin
			s_o <= par_r[16];
			valid_o <= 1'b1;
		end
		
		SERIAL_20: begin
			s_o <= par_r[17];
			valid_o <= 1'b1;
		end
		
		SERIAL_21: begin
			s_o <= par_r[18];
			valid_o <= 1'b1;
		end
		
		SERIAL_22: begin
			s_o <= par_r[19];
			valid_o <= 1'b1;
		end
		
		SERIAL_23: begin
			s_o <= par_r[20];
			valid_o <= 1'b1;
		end
		
		SERIAL_24: begin
			s_o <= par_r[21];
			valid_o <= 1'b1;
		end
		
		SERIAL_25: begin
			s_o <= par_r[22];
			valid_o <= 1'b1;
		end
		
		SERIAL_26: begin
			s_o <= par_r[23];
			valid_o <= 1'b1;
		end
		
		SERIAL_27: begin
			s_o <= (^par_r[23:16]);
			valid_o <= 1'b1;
		end
		
		SERIAL_28: begin
			s_o <= par_r[24];
			valid_o <= 1'b1;
		end
		
		SERIAL_29: begin
			s_o <= par_r[25];
			valid_o <= 1'b1;
		end
		
		SERIAL_30: begin
			s_o <= par_r[26];
			valid_o <= 1'b1;
		end
		
		SERIAL_31: begin
			s_o <= par_r[27];
			valid_o <= 1'b1;
		end
		
		SERIAL_32: begin
			s_o <= par_r[28];
			valid_o <= 1'b1;
		end
		
		SERIAL_33: begin
			s_o <= par_r[29];
			valid_o <= 1'b1;
		end
		
		SERIAL_34: begin
			s_o <= par_r[30];
			valid_o <= 1'b1;
		end
		
		SERIAL_35: begin
			s_o <= par_r[31];
			valid_o <= 1'b1;
		end
		
		SERIAL_36: begin
			s_o <= (^par_r[31:24]);
			valid_o <= 1'b1;
			last_o <= 1'b1;
		end

	endcase
end

always_comb begin
	
	case (State)
		READY: begin
			NextState = READY;
		end
		
		SERIAL_1: begin
			NextState <= SERIAL_2;
		end
		
		SERIAL_2: begin
			NextState = SERIAL_3;
		end
		
		SERIAL_3: begin
			NextState = SERIAL_4;
		end
		
		SERIAL_4: begin
			NextState = SERIAL_5;
		end
		
		SERIAL_5: begin
			NextState = SERIAL_6;
		end
		
		SERIAL_6: begin
			NextState = SERIAL_7;
		end
		
		SERIAL_7: begin
			NextState = SERIAL_8;
		end
		
		SERIAL_8: begin
			NextState = SERIAL_9;
		end
		
		SERIAL_9: begin
			NextState = SERIAL_10;
		end
		
		SERIAL_10: begin
			NextState = SERIAL_11;
		end
		
		SERIAL_11: begin
			NextState = SERIAL_12;
		end
		
		SERIAL_12: begin
			NextState = SERIAL_13;
		end
		
		SERIAL_13: begin
			NextState = SERIAL_14;
		end
		
		SERIAL_14: begin
			NextState = SERIAL_15;
		end
		
		SERIAL_15: begin
			NextState = SERIAL_16;
		end
		
		SERIAL_16: begin
			NextState = SERIAL_17;
		end
		
		SERIAL_17: begin
			NextState = SERIAL_18;
		end
		
		SERIAL_18: begin
			NextState = SERIAL_19;
		end
		
		SERIAL_19: begin
			NextState = SERIAL_20;
		end
		
		SERIAL_20: begin
			NextState = SERIAL_21;
		end
		
		SERIAL_21: begin
			NextState = SERIAL_22;
		end
		
		SERIAL_22: begin
			NextState = SERIAL_23;
		end
		
		SERIAL_23: begin
			NextState = SERIAL_24;
		end
		
		SERIAL_24: begin
			NextState = SERIAL_25;
		end
		
		SERIAL_25: begin
			NextState = SERIAL_26;
		end
		
		SERIAL_26: begin
			NextState = SERIAL_27;
		end
		
		SERIAL_27: begin
			NextState = SERIAL_28;
		end
		
		SERIAL_28: begin
			NextState = SERIAL_29;
		end
		
		SERIAL_29: begin
			NextState = SERIAL_30;
		end
		
		SERIAL_30: begin
			NextState = SERIAL_31;
		end
		
		SERIAL_31: begin
			NextState = SERIAL_32;
		end
		
		SERIAL_32: begin
			NextState = SERIAL_33;
		end
		
		SERIAL_33: begin
			NextState = SERIAL_34;
		end
		
		SERIAL_34: begin
			NextState = SERIAL_35;
		end
		
		SERIAL_35: begin
			NextState = SERIAL_36;
		end
		
		SERIAL_36: begin
			NextState = WAIT_1;
		end
		
		WAIT_1: begin
			if (ack_i) NextState = DONE;
			else if (nack_i) NextState = SERIAL_1;
			else NextState = WAIT_2;
		end
		
		WAIT_2: begin
			if (ack_i) NextState = DONE;
			else if (nack_i) NextState = SERIAL_1;
			else NextState = WAIT_3;
		end
		
		
		WAIT_3: begin
			if (ack_i) NextState = DONE;
			else if (nack_i) NextState = SERIAL_1;
			else NextState = WAIT_4;
		end
		
		WAIT_4: begin
			if (ack_i) NextState = DONE;
			else if (nack_i) NextState = SERIAL_1;
			else NextState = WAIT_5;
		end
		
		WAIT_5: begin
			if (ack_i) NextState = DONE;
			else if (nack_i) NextState = SERIAL_1;
			else NextState = WAIT_6;
		end
		
		WAIT_6: begin
			if (ack_i) NextState = DONE;
			else if (nack_i) NextState = SERIAL_1;
			else NextState = WAIT_7;
		end
		
		WAIT_7: begin
			if (ack_i) NextState = DONE;
			else if (nack_i) NextState = SERIAL_1;
			else NextState = WAIT_8;
		end
		
		WAIT_8: begin
			if (ack_i) NextState = DONE;
			else NextState = SERIAL_1;
		end
		
		DONE: begin
			NextState = DONE;
		end
	
	endcase
end

//rdy_o logic
always_comb begin
	if (~last_o) rdy_o = 1'b0; 
	else rdy_o = 1'b1;
end


endmodule : piso_converter
