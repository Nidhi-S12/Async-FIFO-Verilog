module fifo_mem #(
    parameter DATA_WIDTH = 8,   // Size of each data word
    parameter ADDR_WIDTH = 4    // 2^4 = 16 locations deep
)(
    input w_clk,                // Write clock
    input w_en,                 // Write enable (only write if FIFO isn't full)
    input [ADDR_WIDTH-1:0] w_addr, 
    input [DATA_WIDTH-1:0] w_data,
    input [ADDR_WIDTH-1:0] r_addr,
    output [DATA_WIDTH-1:0] r_data
);

    // Define the memory array (The "Bucket")
    localparam DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Write Operation (Synchronous to w_clk)
    always @(posedge w_clk) begin
        if (w_en) begin
            mem[w_addr] <= w_data;
        end
    end

    // Read Operation (Continuous/Asynchronous to w_clk)
    // Note: We use the read clock in the top-level logic to gate this
    assign r_data = mem[r_addr];

endmodule