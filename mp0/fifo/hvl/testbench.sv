`ifndef testbench
`define testbench

import fifo_types::*;

module testbench(fifo_itf itf);

fifo_synch_1r1w dut (
    .clk_i     ( itf.clk     ),
    .reset_n_i ( itf.reset_n ),

    // valid-ready enqueue protocol
    .data_i    ( itf.data_i  ),
    .valid_i   ( itf.valid_i ),
    .ready_o   ( itf.rdy     ),

    // valid-yumi deqeueue protocol
    .valid_o   ( itf.valid_o ),
    .data_o    ( itf.data_o  ),
    .yumi_i    ( itf.yumi    )
);

// Clock Synchronizer for Student Use
default clocking tb_clk @(negedge itf.clk); endclocking

task reset();
    itf.reset_n <= 1'b0;
    ##(10);
    itf.reset_n <= 1'b1;
    ##(1);
endtask : reset

function automatic void report_error(error_e err);
    itf.tb_report_dut_error(err);
endfunction : report_error

// DO NOT MODIFY CODE ABOVE THIS LINE

word_t out_val;


initial begin
    reset();
    /************************ Your Code Here ***********************/
    // Feel free to make helper tasks / functions, initial / always blocks, etc.

	 //Asserting ready_o
	 itf.reset_n <= 1'b0;
	 @(tb_clk) begin
		reset_to_ready: assert(itf.rdy)
		else begin report_error(RESET_DOES_NOT_CAUSE_READY_O); end
	 end
	 itf.reset_n <= 1'b1;
    ##1;

	 //Testing enqueue + enqueue/dequeue cycles
	 for (int i = 0; i < 255; i++) begin

		//first enqueue
		itf.data_i <= 'd5;
		itf.valid_i <= 1'b1;
	   ##1;
		itf.valid_i <= 1'b0;
		##1;
		//then euqueue/dequeue
		itf.data_i <= 'd5;
		itf.valid_i <= 1'b1;
		itf.yumi <= 1'b1;
		@(tb_clk) begin
			out_val <= itf.data_o;
			##1;
			yumi_to_output: assert(out_val == 'd5)
			else begin report_error(INCORRECT_DATA_O_ON_YUMI_I); end
		end

		itf.valid_i <= 1'b0;
		itf.yumi <= 1'b0;
		##1;

	 end

	 //enqueue at cap_p-1
	 itf.data_i <= 'd5;
	 itf.valid_i <= 1'b1;
    ##1;
    itf.valid_i <= 1'b0;
	 ##1;

	 //Testing dequeue only
	 for (int i = 0; i < 255; i++) begin
		itf.yumi <= 1'b1;
		@(tb_clk) begin
			out_val <= itf.data_o;
			##1;
			yumi_to_output: assert(out_val == 'd5)
			else begin report_error(INCORRECT_DATA_O_ON_YUMI_I); end
		end

		itf.yumi <= 1'b0;
		##1;

	 end

    /***************************************************************/
    // Make sure your test bench exits by calling itf.finish();
    itf.finish();
    $error("TB: Illegal Exit ocurred");
end

endmodule : testbench
`endif
