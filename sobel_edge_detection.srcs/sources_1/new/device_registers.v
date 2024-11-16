`timescale 1ns / 1ps

module device_registers(
    // Device register block interface
    input  wire       i_clk,
    input  wire       i_wr_req,
    input  wire       i_rd_req,
    input  wire [6:0] i_wr_addr,
    input  wire [6:0] i_rd_addr,
    input  wire [7:0] i_wr_data,
    output wire [7:0] o_rd_data,
    // Registers
    output wire [7:0] o_reg_threshold,
    output wire [7:0] o_reg_kernel_size,
    output wire [7:0] o_reg_noise_reduction
);
    
    // Register addresses, contiguous for simpler multi-byte SPI transfers
    localparam [6:0] reg_threshold_addr       = 7'h00;
    localparam [6:0] reg_kernel_size_addr     = 7'h01;
    localparam [6:0] reg_noise_reduction_addr = 7'h02;

    // 2FF synchronizer to cross from SPI clock domain to Global 100MHz clock domain, 
    reg wr_req_ff0      = 1'b0;
    reg wr_req_ff1      = 1'b0;
    reg wr_req_ff2      = 1'b0;
    reg rd_req_ff0      = 1'b0;
    reg rd_req_ff1      = 1'b0;
    reg rd_req_ff2      = 1'b0;
    
    // device registers interface signals
    reg       r_wr_en   = 1'b0;
    reg       r_rd_en   = 1'b0;
    reg [6:0] r_wr_addr = 7'b0;
    reg [6:0] r_rd_addr = 7'b0;
    reg [7:0] r_wr_data = 8'b0;
    reg [7:0] r_rd_data = 8'b0;
    
    // internal registers
    reg  [7:0] r_reg_threshold       = 8'd64;
    reg  [7:0] r_reg_kernel_size     = 8'd128;
    reg  [7:0] r_reg_noise_reduction = 8'b00000000;

    // Pass write request signal through 2FF synchronizer
    always @ (posedge i_clk)
    begin
        // Generate write enable
        r_wr_en <= 1'b0;
        if (wr_req_ff2 & ~wr_req_ff1)
        begin
            r_wr_addr <= i_wr_addr;
            r_wr_data <= i_wr_data;
            r_wr_en   <= 1'b1;
        end
        wr_req_ff2 <= wr_req_ff1;
        wr_req_ff1 <= wr_req_ff0;
        wr_req_ff0 <= i_wr_req;
        
        // Generate read enable
        r_rd_en <= 1'b0;
        if (rd_req_ff2 & ~rd_req_ff1)
        begin
            r_rd_addr <= i_rd_addr;
            r_rd_en   <= 1'b1;
        end
        rd_req_ff2 <= rd_req_ff1;
        rd_req_ff1 <= rd_req_ff0;
        rd_req_ff0 <= i_rd_req;
    end

    // Register writes
    always @ (posedge i_clk)
    begin
        if (r_wr_en)
        begin
            case (r_wr_addr)
                reg_threshold_addr       : r_reg_threshold       <= r_wr_data;
                reg_kernel_size_addr     : r_reg_kernel_size     <= r_wr_data;
                reg_noise_reduction_addr : r_reg_noise_reduction <= r_wr_data;
            endcase
        end
    end
    
    // Register reads
    // Be careful about read enable width, and resetting rd_data_r register value
    always @ (posedge i_clk)
    begin
        if (r_rd_en)
        begin
            case (r_rd_addr)
                reg_threshold_addr       : r_rd_data <= r_reg_threshold;
                reg_kernel_size_addr     : r_rd_data <= r_reg_kernel_size;
                reg_noise_reduction_addr : r_rd_data <= r_reg_noise_reduction;
            endcase
        end
    end
    // Read data connected to internal read data register
    assign o_rd_data = r_rd_data;
    
    // Debug registers output to other modules
    assign o_reg_threshold       = r_reg_threshold;
    assign o_reg_kernel_size     = r_reg_kernel_size;
    assign o_reg_noise_reduction = r_reg_noise_reduction;
    
endmodule
