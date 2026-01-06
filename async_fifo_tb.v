`timescale 1ns/1ps

module async_fifo_tb;
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    reg w_clk, w_rst_n, w_en;
    reg [DATA_WIDTH-1:0] w_data;
    wire full;

    reg r_clk, r_rst_n, r_en;
    wire [DATA_WIDTH-1:0] r_data;
    wire empty;

    // Instantiate the FIFO
    async_fifo #(DATA_WIDTH, ADDR_WIDTH) uut (
        .w_clk(w_clk), .w_rst_n(w_rst_n), .w_en(w_en), .w_data(w_data), .full(full),
        .r_clk(r_clk), .r_rst_n(r_rst_n), .r_en(r_en), .r_data(r_data), .empty(empty)
    );

    // Generate Write Clock (100MHz -> 10ns period)
    always #5 w_clk = ~w_clk;

    // Generate Read Clock (40MHz -> 25ns period)
    always #12.5 r_clk = ~r_clk;

    initial begin
        // Initialize everything
        w_clk = 0; r_clk = 0;
        w_rst_n = 0; r_rst_n = 0;
        w_en = 0; r_en = 0; w_data = 0;

        // Reset the system
        #20 w_rst_n = 1; r_rst_n = 1;
        $display("--- Starting FIFO Test ---");

        // Step 1: Write data until FULL
        @(posedge w_clk);
        while (!full) begin
            w_en = 1;
            w_data = w_data + 1;
            @(posedge w_clk);
        end
        w_en = 0;
        $display("FIFO is FULL. Last data written: %d", w_data);

        // Step 2: Read data until EMPTY
        @(posedge r_clk);
        while (!empty) begin
            r_en = 1;
            @(posedge r_clk);
            $display("Read Data: %d", r_data);
        end
        r_en = 0;
        $display("FIFO is EMPTY.");

        #100;
        $display("--- Test Complete ---");
        $finish;
    end

    // Create a wave file for GTKWave
    initial begin
        $dumpfile("fifo_waves.vcd");
        $dumpvars(0, async_fifo_tb);
    end
endmodule