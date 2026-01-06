module r_ptr_empty #(parameter ADDR_WIDTH = 4) (
    input r_clk, r_rst_n, r_en,
    input [ADDR_WIDTH:0] r_q2_wptr, // Synchronized write pointer coming IN
    output reg [ADDR_WIDTH:0] r_ptr, // Gray code pointer going OUT
    output [ADDR_WIDTH-1:0] r_addr,  // Binary address for the Memory
    output reg empty
);
    reg [ADDR_WIDTH:0] binary_ptr;
    wire [ADDR_WIDTH:0] binary_next, gray_next;

    // 1. Calculate next pointers
    assign binary_next = binary_ptr + (r_en && !empty);
    assign gray_next = (binary_next >> 1) ^ binary_next;

    // 2. Address for memory
    assign r_addr = binary_ptr[ADDR_WIDTH-1:0];

    always @(posedge r_clk or negedge r_rst_n) begin
        if (!r_rst_n) begin
            binary_ptr <= 0;
            r_ptr <= 0;
        end else begin
            binary_ptr <= binary_next;
            r_ptr <= gray_next;
        end
    end

    // 3. The "Empty" Check
    // If the Write Gray Pointer and Read Gray Pointer are identical, it's empty.
    wire empty_val = (gray_next == r_q2_wptr);

    always @(posedge r_clk or negedge r_rst_n) begin
        if (!r_rst_n) empty <= 1'b1;
        else          empty <= empty_val;
    end
endmodule