module cdc_sync #(
    parameter ADDR_WIDTH = 4
)(
    input clk,              // The clock of the domain we are ENTERING
    input rst_n,            // Reset
    input [ADDR_WIDTH:0] d_in,   // The pointer coming from the OTHER clock
    output reg [ADDR_WIDTH:0] d_out // The safe, synchronized pointer
);

    reg [ADDR_WIDTH:0] sync_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_reg <= 0;
            d_out <= 0;
        end else begin
            sync_reg <= d_in;    // First stage: Capture the signal
            d_out <= sync_reg;   // Second stage: Let the signal "settle"
        end
    end

endmodule