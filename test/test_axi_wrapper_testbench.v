`timescale 1ns / 1ps
`define ZYNQ_VIP_0 test_axi_wrapper_testbench.test_axi_i.zynq_ultra_ps_e_0.inst

module test_axi_wrapper_testbench;

test_axi test_axi_i();

reg tb_ACLK;
reg tb_ARESETn;

wire temp_clk;
wire temp_rstn; 

reg [63:0] read_data;
reg [127:0] read_data128;
reg resp;
reg [7:0] irq_status;
reg [31:0] src_data;
reg [31:0] dst_data;

integer cdma_tb_pass = 1;
  
initial 
begin       
    tb_ACLK = 1'b0;
end

//------------------------------------------------------------------------
// Simple Clock Generator
//------------------------------------------------------------------------

always #10 tb_ACLK = !tb_ACLK;
   
initial
begin

    $display ("running the tb");
    
    tb_ARESETn = 1'b0;
    repeat(200)@(posedge tb_ACLK);        
    tb_ARESETn = 1'b1;
    @(posedge tb_ACLK);
    
    repeat(5) @(posedge tb_ACLK);
      
    //Reset the PL zynq_ultra_ps_e_0   Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0
    `ZYNQ_VIP_0.por_srstb_reset(1'b0);
    `ZYNQ_VIP_0.fpga_soft_reset(32'h1);   
    #200;  // This delay depends on your clock frequency. It should be at least 16 clock cycles. 
    `ZYNQ_VIP_0.por_srstb_reset(1'b1);
    `ZYNQ_VIP_0.fpga_soft_reset(32'h0);
    
    // Set debug level info to off. For more info, set to 1.
    `ZYNQ_VIP_0.set_debug_level_info(0);
    `ZYNQ_VIP_0.set_stop_on_error(1);
    // Set minimum port verbosity. Change to 32'd400 for maximum.
    // `ZYNQ_VIP_0.M_AXI_HPM0_FPD.set_verbosity(32'd0);
    // `ZYNQ_VIP_0.S_AXI_HP0_FPD.set_verbosity(32'd0);
    `ZYNQ_VIP_0.M_AXI_HPM0_LPD.set_verbosity(32'd0);
    
    //Fill the source data area
    // `ZYNQ_VIP_0.pre_load_mem(2'b00, 32'h00010000, 4096); // Write Random
    
    //Configure CDMA transfer        
    //The M_AXI_HPM0_FPD interface is configured for 128 bits.
    //Use the write_burst_strb command to control which bytes on the interface to enable for the CDMA register writes.
    //Use the read_burst command to control which bytes on the interface to return for the CDMA register reads.
   
    // Read status
    // read_burst(address, len, size, burst type, lock, cache, prot, data, response)
    `ZYNQ_VIP_0.read_burst(40'h00_8000_0000, 4'h0, 3'b010, 2'b01, 2'b00, 4'h0, 3'b000, read_data, resp);
    $display ("%t, cnt = %x",$time, read_data[63:0]);
    repeat(5) @(posedge tb_ACLK);
    `ZYNQ_VIP_0.read_burst(40'h00_8000_0008, 4'h0, 3'b010, 2'b01, 2'b00, 4'h0, 3'b000, read_data, resp);
    $display ("%t, run = %x",$time, read_data[63:0]);
    repeat(5) @(posedge tb_ACLK);

    // write trigger
    // write_burst_strb(addr, len, size, burst, lock, cache, prot, data, strb_en, strb, datasize, resp);
    `ZYNQ_VIP_0.write_burst_strb(40'h00_8000_0010, 4'h0, 3'b010, 2'b01, 2'b00, 4'h0, 3'b000, 1, 1, 8'hFF, 8, resp);
    repeat(5) @(posedge tb_ACLK);
    `ZYNQ_VIP_0.write_burst_strb(40'h00_8000_0010, 4'h0, 3'b010, 2'b01, 2'b00, 4'h0, 3'b000, 2, 1, 8'hFF, 8, resp);
    repeat(5) @(posedge tb_ACLK);
    `ZYNQ_VIP_0.write_burst_strb(40'h00_8000_0010, 4'h0, 3'b010, 2'b01, 2'b00, 4'h0, 3'b000, 3, 1, 8'hFF, 8, resp);
    repeat(5) @(posedge tb_ACLK);
    
    // read_burst(address, len, size, burst type, lock, cache, prot, data, response)
    // The cnt should be 1+2+3=6
    `ZYNQ_VIP_0.read_burst(40'h00_8000_0000, 4'h0, 3'b010, 2'b01, 2'b00, 4'h0, 3'b000, read_data, resp);
    $display ("%t, cnt = %x",$time, read_data[63:0]);
    repeat(5) @(posedge tb_ACLK);
    `ZYNQ_VIP_0.read_burst(40'h00_8000_0008, 4'h0, 3'b010, 2'b01, 2'b00, 4'h0, 3'b000, read_data, resp);
    $display ("%t, run = %x",$time, read_data[63:0]);
    repeat(5) @(posedge tb_ACLK);

    // write run
    // write_burst_strb(addr, len, size, burst, lock, cache, prot, data, strb_en, strb, datasize, resp);
    `ZYNQ_VIP_0.write_burst_strb(40'h00_8000_0008, 4'h0, 3'b010, 2'b01, 2'b00, 4'h0, 3'b000, 1, 1, 8'hFF, 8, resp);
    repeat(5) @(posedge tb_ACLK);

    // The cnt should be slightly greater, depending on the clock rate
    `ZYNQ_VIP_0.read_burst(40'h00_8000_0000, 4'h0, 3'b010, 2'b01, 2'b00, 4'h0, 3'b000, read_data, resp);
    $display ("%t, cnt = %x",$time, read_data[63:0]);
    repeat(5) @(posedge tb_ACLK);
    `ZYNQ_VIP_0.read_burst(40'h00_8000_0008, 4'h0, 3'b010, 2'b01, 2'b00, 4'h0, 3'b000, read_data, resp);
    $display ("%t, run = %x",$time, read_data[63:0]);
    repeat(5) @(posedge tb_ACLK);
     
    // Wait for interrupt
    /*`ZYNQ_VIP_0.wait_interrupt(4'h0,irq_status);
    
    if(irq_status & 8'h01) begin
        $display("SUCCESS: CDMA interrupt received");
    end
    else begin
        $display("FAILURE: CDMA interrupt not received");
        cdma_tb_pass = 0;
    end
    */ 
    
    $display("Testbench finished");
    $finish;

end

   assign temp_clk = tb_ACLK;
   assign temp_rstn = tb_ARESETn;

endmodule
