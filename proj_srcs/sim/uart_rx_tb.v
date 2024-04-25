`timescale 1ns / 1ps

// File :            uart_rx_tb.v
// Title :           uart_rx_tb
//
// Author(s) :       Jonathan Roa
//
// Description :     Testbench for UART RX module, run for 130ms
//
// Revisions 
//
// Date        Name            REV#        Description 
// ----------  --------------- ----------- -------------------------------------------
// (04/19/24)  Jonathan Roa    1.0         Initial Revision

module uart_rx_tb ();

    localparam p_CLK_PERIOD     = 8;
    localparam p_DATA_WIDTH     = 8;
    localparam p_BAUD_SEL_WIDTH = 3;
    localparam p_STIM_QTY       = 5;

    reg                         r_clk;
    reg                         r_rst_n;
    reg  [p_BAUD_SEL_WIDTH-1:0] r_baud_sel; 
    reg  [p_DATA_WIDTH-1:0]     r_tx_data; 
    reg                         r_wr_en;
    wire                        w_tx_data;
    wire                        w_tx_running;
    wire                        w_tx_done;

    wire [p_DATA_WIDTH-1:0]     w_rx_data; 
    wire                        w_rx_running;
    wire                        w_rx_done;
    
    integer                     error_cnt;
    integer                     index;
    reg  [p_DATA_WIDTH-1:0]     test_stim [p_STIM_QTY-1:0] = {
                                                               8'hAA,
                                                               8'h7B,
                                                               8'h03,
                                                               8'h28,
                                                               8'h12
                                                             };

    uart_tx inst_uart_tx (
        .i_clk        (r_clk),
        .i_rst_n      (r_rst_n),
        .i_baud_sel   (r_baud_sel),
        .i_tx_data    (r_tx_data),
        .i_wr_en      (r_wr_en),

        .o_tx_data    (w_tx_data),
        .o_tx_running (w_tx_running),
        .o_tx_done    (w_tx_done)
    );

    uart_rx UUT_uart_rx (
        .i_clk        (r_clk),
        .i_rst_n      (r_rst_n),
        .i_baud_sel   (r_baud_sel),
        .i_tx_data    (w_tx_data),

        .o_rx_data    (w_rx_data),
        .o_rx_running (w_rx_running),
        .o_rx_done    (w_rx_done)
    ); 

    // Generate the clock
    always begin
        #(p_CLK_PERIOD/2); r_clk <= ~r_clk;
    end

    initial begin

        error_cnt <= 0;

        // Test 1: 9600 baud
        init();
        set_baud(3'b000);
        assert_reset(); wait_5ms();
        for (index = 0; index < p_STIM_QTY; index = index + 1) begin
        transmit(test_stim[index]); wait_5ms();
            if (w_rx_data != test_stim[index]) begin
                error_cnt <= error_cnt + 1;
                $error  ("INCORRECT OUTPUT");
                $display("Error occurred at: ", $time);
                $write  ("Expected: %H ", test_stim[index]);
                $display("Actual: %H ", w_rx_data);
            end else begin
                error_cnt <= error_cnt;
            end
        end

        // Test 2: 4800 baud
        init();
        set_baud(3'b001);
        assert_reset();
        for (index = 0; index < p_STIM_QTY; index = index + 1) begin
        transmit(test_stim[index]); wait_5ms();
            if (w_rx_data != test_stim[index]) begin
                error_cnt <= error_cnt + 1;
                $error  ("INCORRECT OUTPUT");
                $display("Error occurred at: ", $time);
                $write  ("Expected: %H ", test_stim[index]);
                $display("Actual: %H ", w_rx_data);
            end else begin
                error_cnt <= error_cnt;
            end
        end

        // Test 3: 19200 baud
        init();
        set_baud(3'b010);
        assert_reset();
        for (index = 0; index < p_STIM_QTY; index = index + 1) begin
        transmit(test_stim[index]); wait_5ms();
            if (w_rx_data != test_stim[index]) begin
                error_cnt <= error_cnt + 1;
                $error  ("INCORRECT OUTPUT");
                $display("Error occurred at: ", $time);
                $write  ("Expected: %H ", test_stim[index]);
                $display("Actual: %H ", w_rx_data);
            end else begin
                error_cnt <= error_cnt;
            end
        end

        // Test 4: 57600 baud
        init();
        set_baud(3'b011);
        assert_reset();
        for (index = 0; index < p_STIM_QTY; index = index + 1) begin
        transmit(test_stim[index]); wait_5ms();
            if (w_rx_data != test_stim[index]) begin
                error_cnt <= error_cnt + 1;
                $error  ("INCORRECT OUTPUT");
                $display("Error occurred at: ", $time);
                $write  ("Expected: %H ", test_stim[index]);
                $display("Actual: %H ", w_rx_data);
            end else begin
                error_cnt <= error_cnt;
            end
        end

        // Test 5: 115200 baud
        init();
        set_baud(3'b100);
        assert_reset();
        for (index = 0; index < p_STIM_QTY; index = index + 1) begin
        transmit(test_stim[index]); wait_5ms();
            if (w_rx_data != test_stim[index]) begin
                error_cnt <= error_cnt + 1;
                $error  ("INCORRECT OUTPUT");
                $display("Error occurred at: ", $time);
                $write  ("Expected: %H ", test_stim[index]);
                $display("Actual: %H ", w_rx_data);
            end else begin
                error_cnt <= error_cnt;
            end
        end

        $display("Error count: %2D", error_cnt);
        if (error_cnt == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("REVIEW SIM RESULTS");
        end
    end

    task transmit(input [7:0] tx_data); begin
        r_tx_data <= tx_data;
        #(p_CLK_PERIOD);
        r_wr_en <= 1'b1; #(p_CLK_PERIOD);
        r_wr_en <= 1'b0;
    end
    endtask

    task assert_reset(); begin
        r_rst_n <= 1'b0; #(p_CLK_PERIOD*5);
        r_rst_n <= 1'b1;
    end
    endtask

    task wait_5ms(); begin
        #(p_CLK_PERIOD*625000);
    end
    endtask

    task set_baud(input [p_BAUD_SEL_WIDTH-1:0] baud_sel); begin
        r_baud_sel <= baud_sel;
    end
    endtask

    task init(); begin
        r_clk      <= 1'b1;
        r_rst_n    <= 1'b1;
        r_baud_sel <= {p_BAUD_SEL_WIDTH{1'b0}};
        r_tx_data  <= 1'b1;
        r_wr_en    <= 1'b0;
    end
    endtask
   
endmodule
