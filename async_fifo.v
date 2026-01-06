module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input w_clk, w_rst_n, w_en,
    input [DATA_WIDTH-1:0] w_data,
    output full,
    
    input r_clk, r_rst_n, r_en,
    output [DATA_WIDTH-1:0] r_data,
    output empty
);

    wire [ADDR_WIDTH-1:0] w_addr, r_addr;
    wire [ADDR_WIDTH:0] w_ptr, r_ptr, w_q2_rptr, r_q2_wptr;

    // 1. The Synchronizers (The Airlocks)
    // Synchronize Read Pointer into Write Clock Domain
    cdc_sync #(ADDR_WIDTH) sync_r2w (
        .clk(w_clk), .rst_n(w_rst_n), .d_in(r_ptr), .d_out(w_q2_rptr)
    );

    // Synchronize Write Pointer into Read Clock Domain
    cdc_sync #(ADDR_WIDTH) sync_w2r (
        .clk(r_clk), .rst_n(r_rst_n), .d_in(w_ptr), .d_out(r_q2_wptr)
    );

    // 2. The Memory Array
    fifo_mem #(DATA_WIDTH, ADDR_WIDTH) mem (
        .w_clk(w_clk), .w_en(w_en && !full), .w_addr(w_addr),
        .w_data(w_data), .r_addr(r_addr), .r_data(r_data)
    );

    // 3. The Write Logic
    w_ptr_full #(ADDR_WIDTH) w_logic (
        .w_clk(w_clk), .w_rst_n(w_rst_n), .w_en(w_en),
        .w_q2_rptr(w_q2_rptr), .w_ptr(w_ptr), .w_addr(w_addr), .full(full)
    );

    // 4. The Read Logic
    r_ptr_empty #(ADDR_WIDTH) r_logic (
        .r_clk(r_clk), .r_rst_n(r_rst_n), .r_en(r_en),
        .r_q2_wptr(r_q2_wptr), .r_ptr(r_ptr), .r_addr(r_addr), .empty(empty)
    );

endmodule