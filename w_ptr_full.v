module w_ptr_full #(parameter ADDR_WIDTH = 4) (
    input w_clk, w_rst_n, w_en,
    input [ADDR_WIDTH:0] w_q2_rptr, // Synchronized read pointer coming IN
    output reg [ADDR_WIDTH:0] w_ptr, // Gray code pointer going OUT
    output [ADDR_WIDTH-1:0] w_addr,  // Binary address for the Memory
    output reg full
);
    reg [ADDR_WIDTH:0] binary_ptr;
    wire [ADDR_WIDTH:0] binary_next, gray_next;

    // 1. Calculate the next Binary and Gray pointers
    assign binary_next = binary_ptr + (w_en && !full);
    assign gray_next = (binary_next >> 1) ^ binary_next; // Binary to Gray conversion
    
    // 2. Memory address is just the lower bits of the binary pointer
    assign w_addr = binary_ptr[ADDR_WIDTH-1:0];

    always @(posedge w_clk or negedge w_rst_n) begin
        if (!w_rst_n) begin
            binary_ptr <= 0;
            w_ptr <= 0;
        end else begin
            binary_ptr <= binary_next;
            w_ptr <= gray_next;
        end
    end

    // 3. The "Full" Check
    // A FIFO is full if the Write Gray Pointer is the "mirror" of the Read Gray Pointer
    wire full_val = (gray_next == {~w_q2_rptr[ADDR_WIDTH:ADDR_WIDTH-1], w_q2_rptr[ADDR_WIDTH-2:0]});

    always @(posedge w_clk or negedge w_rst_n) begin
        if (!w_rst_n) full <= 0;
        else          full <= full_val;
    end
endmodule