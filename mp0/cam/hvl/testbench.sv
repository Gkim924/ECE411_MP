import cam_types::*;

module testbench(cam_itf itf);

cam dut (
    .clk_i     ( itf.clk     ),
    .reset_n_i ( itf.reset_n ),
    .rw_n_i    ( itf.rw_n    ),
    .valid_i   ( itf.valid_i ),
    .key_i     ( itf.key     ),
    .val_i     ( itf.val_i   ),
    .val_o     ( itf.val_o   ),
    .valid_o   ( itf.valid_o )
);

default clocking tb_clk @(negedge itf.clk); endclocking

task reset();
    itf.reset_n <= 1'b0;
    repeat (5) @(tb_clk);
    itf.reset_n <= 1'b1;
    repeat (5) @(tb_clk);
endtask

// DO NOT MODIFY CODE ABOVE THIS LINE

task write(input key_t key, input val_t val);

	itf.rw_n <= 1'b0;
	itf.valid_i <= 1'b1;
	itf.key <= key;
	itf.val_i <= val;

	##1;
	
endtask

task read(input key_t key, output val_t val);
	
	itf.rw_n <= 1'b1;
	itf.valid_i <= 1'b1;
	itf.key <= key;
	
	##1;
	
	@(tb_clk iff(itf.valid_o)) begin
		val <= itf.val_o;
		##1;
	end
	
endtask

val_t out_val;

initial begin
    $display("Starting CAM Tests");

    reset();
	 /*************************Contents Table***************************/
	 // 1 ---------- 3
	 // 2 ---------- 4
	 // **************
	 // 16 ---------- 18
	 
	 /******************************************************************
    /************************** Your Code Here ****************************/
    // Feel free to make helper tasks / functions, initial / always blocks, etc.
    // Consider using the task skeltons above
    // To report errors, call itf.tb_report_dut_error in cam/include/cam_itf.sv
	
	 //Testing evict
	 for (int i = 1; i <= 'd16; i++) begin
	 
		write(i, (i + 'd2));
	   
	   ##1;
		
	 end
	 
	 //Testing read-hits
	 reset();
	 for (int i = 1; i <= 'd8; i++) begin
	 
		write(i, (i + 'd2));
		
	   ##1;
		
	 end
	 
	 for (int i = 1; i <= 'd8; i++) begin
	 
		read(i, out_val);
		
		check_cor_val: assert(out_val == (i+2))
			else begin itf.tb_report_dut_error(READ_ERROR); $error("\t error happens at %0d", 'd6); end
			
	   ##1;
		
	 end
	 
	 
	 //Testing write to a same key
	 reset();
	 
	 write('d6, 'd10);
	 write('d6, 'd20);
	 
	 //Testing write-read to a same key
	 reset();
	 
	 write('d6, 'd10);
	 read('d6, out_val);
	 
	 //$display("\t \%0d", out_val);
	 
	 check_cor_val: assert(out_val == 'd10)
		else begin itf.tb_report_dut_error(READ_ERROR); $error("\t error happens at %0d", 'd6); end
	
    /**********************************************************************/

    itf.finish();
end

endmodule : testbench
