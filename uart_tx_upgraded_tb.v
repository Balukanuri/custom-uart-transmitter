module uart_tx_upgraded_tb;

    reg clk = 0;
    reg reset = 1;
    reg start_tx = 0;
    reg [7:0] data_in = 8'hA5;
    wire tx, busy, tx_done;

    // Instantiate upgraded UART TX
    uart_tx_upgraded #(
        .BAUD_DIV(4)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start_tx(start_tx),
        .data_in(data_in),
        .tx(tx),
        .busy(busy),
        .tx_done(tx_done)
    );

    // Clock generation: 100MHz (10ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, uart_tx_upgraded_tb);

        // Initial reset
        #10 reset = 0;

        // Trigger transmission
        #10 start_tx = 1;
        #10 start_tx = 0;

        // Wait until tx_done
        wait (tx_done);
        $display("✅ Transmission completed at time %0t", $time);

        #50 $finish;
    end

endmodule
Added testbench from EDA Playground
