`timescale 1ns / 1ps

module sobel_top(
    input  wire        clk,
    input  wire        sck,
    input  wire        cs,
    input  wire        mosi,
    output wire        miso,
    
    // LEDs
    output wire  [1:0] led,
    output wire        led_r, led_g, led_b
);
    // Unused
    wire       w_locked;
    wire       w_reset  = 1'b0;
    
    // 100MHz global clock (from MMCM)
    wire       clk100m;
    
    wire       wr_req_w;
    wire       rd_req_w;
    wire [6:0] wr_addr_w;
    wire [6:0] rd_addr_w;
    wire [7:0] wr_data_w;
    wire [7:0] rd_data_w;
    
    wire [7:0] w_reg_threshold;
    wire [7:0] w_reg_kernel_size;
    wire [7:0] w_noise_reduction;

    clk_wiz_1         mmcm0 (.clk(clk),
                             .reset(w_reset),
                             .locked(w_locked),
                             .clk100m(clk100m));
                             
    spi_interface     spi0  (.i_sck(sck),
                             .i_cs(cs),
                             .i_copi(copi),
                             .o_cipo(cipo),
                             .o_wr_req(wr_req_w),
                             .o_rd_req(rd_req_w),
                             .o_wr_addr(wr_addr_w),
                             .o_rd_addr(rd_addr_w),
                             .o_wr_data(wr_data_w),
                             .i_rd_data(rd_data_w));
                        
    device_registers  reg0  (.i_clk(clk100m),
                             .i_wr_req(wr_req_w),
                             .i_rd_req(rd_req_w),
                             .i_wr_addr(wr_addr_w),
                             .i_rd_addr(rd_addr_w),
                             .i_wr_data(wr_data_w),
                             .o_rd_data(rd_data_w),
                             .o_reg_threshold(w_reg_threshold),
                             .o_reg_kernel_size(w_reg_kernel_size),
                             .o_reg_noise_reduction(w_noise_reduction));
                             
    assign led   = 2'b11;
    assign led_r = 1'b0;
    assign led_g = 1'b1;
    assign led_b = 1'b0;
                             
endmodule