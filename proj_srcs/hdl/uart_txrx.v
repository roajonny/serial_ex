`timescale 1ns / 1ps

// File :            uart_txrx.v
// Title :           uart_txrx
//
// Author(s) :       Jonathan Roa
//
// Description :     UART transceiver top level - LSB-first, programmable baud rate 
//                   and data width
//
//                   Default 8-bit data and assumes 125 MHz clock
//                   
//                   4800   : baud select 001
//                   9600   : default
//                   19200  : baud select 010
//                   57600  : baud select 011
//                   115200 : baud select 100
//
// Revisions 
//
// Date        Name            REV#        Description 
// ----------  --------------- ----------- -------------------------------------------
// (04/20/24)  Jonathan Roa    1.0         Initial Revision

module uart_txrx #
    (
        parameter p_DATA_WIDTH     = 8,
        parameter p_BAUD_CTR_WIDTH = 16,
        parameter p_BAUD_SEL_WIDTH = 3,

        // Baud counter rollover n = (baud_period/clk_period)
        parameter p_BAUD_4800      = 26042,
        parameter p_BAUD_9600      = 13021,
        parameter p_BAUD_19200     = 6511,
        parameter p_BAUD_57600     = 2171,
        parameter p_BAUD_115200    = 1086
    )
    (
        input  wire                        i_clk,

        input  wire                        i_sin,
        output wire                        o_sout
    );

        // Debug monitoring
        wire [p_BAUD_SEL_WIDTH-1:0] w_baud_sel_vio;
        wire [p_DATA_WIDTH-1:0]     w_tx_data_vio;
        wire                        w_tx_wr_en_vio;
        wire                        w_rst_n_vio;
        wire                        w_tx_wr_en;
        wire                        w_tx_running_dbg;
        wire                        w_tx_done_dbg;
        wire                        w_rx_running_dbg;
        wire                        w_rx_done_dbg;
        (* MARK_DEBUG = "TRUE" *)   wire [p_DATA_WIDTH-1:0]     w_rx_data_dbg;

        uart_tx #
            (
                .p_DATA_WIDTH      (p_DATA_WIDTH),
                .p_BAUD_CTR_WIDTH  (p_BAUD_CTR_WIDTH),
                .p_BAUD_SEL_WIDTH  (p_BAUD_SEL_WIDTH),

                // Baud counter rollover n = (baud_period/clk_period)
                .p_BAUD_4800       (p_BAUD_4800),
                .p_BAUD_9600       (p_BAUD_9600),
                .p_BAUD_19200      (p_BAUD_19200),
                .p_BAUD_57600      (p_BAUD_57600),
                .p_BAUD_115200     (p_BAUD_115200)
            )
        inst_uart_tx 
            (
                .i_clk             (i_clk),
                .i_rst_n           (w_rst_n_vio),

                // Driven by VIO for testing
                .i_baud_sel        (w_baud_sel_vio),
                .i_tx_data         (w_tx_data_vio),

                .i_wr_en           (w_tx_wr_en),

                // Monitored by ILA for testing
                .o_tx_data         (o_sout)
                // .o_tx_running      (w_tx_running_dbg),
                // .o_tx_done         (w_tx_done_dbg)
            );

        uart_rx # 
            (
                .p_DATA_WIDTH      (p_DATA_WIDTH),
                .p_BAUD_CTR_WIDTH  (p_BAUD_CTR_WIDTH),
                .p_BAUD_SEL_WIDTH  (p_BAUD_SEL_WIDTH),

                // Baud counter rollover n = (baud_period/clk_period)
                .p_BAUD_4800       (p_BAUD_4800),
                .p_BAUD_9600       (p_BAUD_9600),
                .p_BAUD_19200      (p_BAUD_19200),
                .p_BAUD_57600      (p_BAUD_57600),
                .p_BAUD_115200     (p_BAUD_115200)
            )
        inst_uart_rx 
            (
                .i_clk             (i_clk),
                .i_rst_n           (w_rst_n_vio),

                // Driven by VIO for testing
                .i_baud_sel        (w_baud_sel_vio),


                // Monitored by ILA for testing
                .i_tx_data         (i_sin),
                .o_rx_data         (w_rx_data_dbg)
                // .o_rx_running      (w_rx_running_dbg),
                // .o_rx_done         (w_rx_done_dbg)
            );

        pulse_gen inst_wr_en_gen
            (
                .i_clk             (i_clk), 
                .i_rst_n           (w_rst_n_vio), 
                
                .i_trigger         (w_tx_wr_en_vio),  
                .o_pulse           (w_tx_wr_en)  
            );

        // Debug monitoring and test control
        ila_0 inst_rx_ila 
            (
            	.clk               (i_clk),          // input wire clk
            	.probe0            (w_rx_data_dbg)   // input wire [7:0] probe0
            );

        vio_0 inst_txrx_vio 
            (
                .clk               (i_clk),          // input wire clk
                .probe_out0        (w_tx_data_vio),  // output wire [7 : 0] probe_out0
                .probe_out1        (w_tx_wr_en_vio), // output wire [0 : 0] probe_out1
                .probe_out2        (w_baud_sel_vio), // output wire [2 : 0] probe_out2
                .probe_out3        (w_rst_n_vio)
            );

endmodule
