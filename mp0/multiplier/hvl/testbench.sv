import mult_types::*;

`ifndef testbench
`define testbench
module testbench(multiplier_itf.testbench itf);

add_shift_multiplier dut (
    .clk_i          ( itf.clk          ),
    .reset_n_i      ( itf.reset_n      ),
    .multiplicand_i ( itf.multiplicand ),
    .multiplier_i   ( itf.multiplier   ),
    .start_i        ( itf.start        ),
    .ready_o        ( itf.rdy          ),
    .product_o      ( itf.product      ),
    .done_o         ( itf.done         )
);

assign itf.mult_op = dut.ms.op;
default clocking tb_clk @(negedge itf.clk); endclocking

// DO NOT MODIFY CODE ABOVE THIS LINE

/* Uncomment to "monitor" changes to adder operational state over time */
//initial $monitor("dut-op: time: %0t op: %s", $time, dut.ms.op.name);


// Resets the multiplier
task reset();
    itf.reset_n <= 1'b0;
    ##5;
    itf.reset_n <= 1'b1;
    ##1;
endtask : reset

// error_e defined in package mult_types in file ../include/types.sv
// Asynchronously reports error in DUT to grading harness
function void report_error(error_e error);
    itf.tb_report_dut_error(error);
endfunction : report_error


initial itf.reset_n = 1'b0;
initial begin
    reset();
    /********************** Your Code Here *****************************/
    // Testing all possible combinations
    for (int i = 0; i <= 'd255; ++i) begin
		for (int j = 0; j <= 'd255; ++j) begin
			check_ready_start: assert(itf.rdy)
			  else begin $error("\t cur_error at i = %0d and j = %0d", i , j); report_error(NOT_READY); end

			itf.multiplicand <= i;
			itf.multiplier <= j;
			itf.start <= 1'b1;

			##1;

			itf.start <= 1'b0;

			##1;
			
			
			@(tb_clk iff (itf.mult_op == DONE)) begin
				check_ready_end: assert(itf.rdy)
				  else begin $error("\t cur_error at i = %0d and j = %0d", itf.multiplicand , itf.multiplier); report_error(NOT_READY); end

				check_mul: assert(itf.product == itf.multiplicand*itf.multiplier)
				  else begin $error("\t cur_error at i = %0d and j = %0d", itf.multiplicand , itf.multiplier); report_error(BAD_PRODUCT); end
			end
			
			##2; 
			
			reset(); 
			
			##1;

			
		end
    end
	 
	 reset();
	 //Asserting start_i and reset_n_i signal 
	 itf.multiplicand <= 'd10;
	 itf.multiplier <= 'd25;
	 itf.start <= 1'b1;

	 ##1;

    itf.start <= 1'b0;

	 ##1;
	
	 @(tb_clk iff (itf.mult_op == ADD)) begin
	
		itf.start <= 1'b1;
		
		##1;
		
		itf.start <= 1'b0;
		
		##1;
		
	 end
	  
	 @(tb_clk iff (itf.mult_op == SHIFT)) begin
	
		itf.start <= 1'b1;
		
		##1;
		
		itf.start <= 1'b0;
		
		##1;
		
	 end
	  
	 @(tb_clk iff (itf.mult_op == ADD)) begin
	
		itf.reset_n <= 1'b0;
		
		##1;
		
		itf.reset_n <= 1'b1;
		
		##1;
		
	 end
	  
	 itf.multiplicand <= 'd10;
	 itf.multiplier <= 'd25;
	 itf.start <= 1'b1;

	 ##1;

    itf.start <= 1'b0;

	 ##1;
	 
	 @(tb_clk iff (itf.mult_op == SHIFT)) begin
	
		itf.reset_n <= 1'b0;
		
		##1;
		
		itf.reset_n <= 1'b1;
		
		##1;
		
	 end
	 
	 
    /*******************************************************************/
    itf.finish(); // Use this finish task in order to let grading harness
                  // complete in process and/or scheduled operations
						
			
			
	 
    $error("Improper Simulation Exit");
end


endmodule : testbench
`endif
