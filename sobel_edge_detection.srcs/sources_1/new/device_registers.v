`timescale 1ns / 1ps

module device_registers(
    // Device register block interface
    input  wire       i_clk,
    input  wire       i_wr_req,
    input  wire       i_rd_req,
    input  wire [6:0] i_wr_addr,
    input  wire [6:0] i_rd_addr,
    input  wire [7:0] i_wr_data,
    output wire [7:0] i_rd_data,
    // Registers
    output wire [7:0] o_reg_threshold,
    output wire [7:0] o_reg_kernel_size
);

    localparam [6:0] reg_threshold_addr   = 7'h00;
    localparam [6:0] reg_kernel_size_addr = 7'h01;

    // 2FF synchronizer to cross from SPI clock domain to Global 100MHz clock domain, 
    reg wr_req_ff0      = 1'b0;
    reg wr_req_ff1      = 1'b0;
    reg wr_req_ff2      = 1'b0;
    reg rd_req_ff0      = 1'b0;
    reg rd_req_ff1      = 1'b0;
    reg rd_req_ff2      = 1'b0;
    
    // device registers interface signals
    reg       wr_en_r   = 1'b0;
    reg       rd_en_r   = 1'b0;
    reg [6:0] wr_addr_r = 7'b0;
    reg [6:0] rd_addr_r = 7'b0;
    reg [7:0] wr_data_r = 8'b0;
    reg [7:0] rd_data_r = 8'b0;
    
    // internal registers
    reg  [7:0] r_reg_threshold   = 8'd64;
    reg  [7:0] r_reg_kernel_size = 8'd128;

    // Pass write request signal through 2FF synchronizer
    always @ (posedge i_clk)
    begin
        // Generate write enable
        wr_en_r <= 1'b0;
        if (wr_req_ff2 & ~wr_req_ff1)
        begin
            wr_addr_r <= i_wr_addr;
            wr_data_r <= i_wr_data;
            wr_en_r   <= 1'b1;
        end
        wr_req_ff2 <= wr_req_ff1;
        wr_req_ff1 <= wr_req_ff0;
        wr_req_ff0 <= i_wr_req;
        
        // Generate read enable
        rd_en_r <= 1'b0;
        if (rd_req_ff2 & ~rd_req_ff1)
        begin
            rd_addr_r <= i_rd_addr;
            rd_en_r   <= 1'b1;
        end
        rd_req_ff2 <= rd_req_ff1;
        rd_req_ff1 <= rd_req_ff0;
        rd_req_ff0 <= i_rd_req;
    end

    // Register writes
    always @ (posedge i_clk)
    begin
        if (wr_en_r)
        begin
            case (wr_addr_r)
                reg_threshold_addr   : r_reg_threshold <= wr_data_r;
                reg_kernel_size_addr : r_reg_kernel_size <= wr_data_r;
            endcase
        end
    end
    
    // Register reads
    // Be careful about read enable width, and resetting rd_data_r register value
    always @ (posedge i_clk)
    begin
        if (rd_en_r)
        begin
            case (rd_addr_r)
                reg_threshold_addr   : rd_data_r <= r_reg_threshold;
                reg_kernel_size_addr : rd_data_r <= r_reg_kernel_size;
            endcase
        end
    end
    // Read data connected to internal read data register
    assign i_rd_data = rd_data_r;
    
    // Debug registers output to other modules
    assign o_reg_threshold   = r_reg_threshold;
    assign o_reg_kernel_size = r_reg_kernel_size;
    
endmodule
