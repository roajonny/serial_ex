`timescale 1ns / 1ps

// File :            uart_tx.v
// Title :           uart_tx
//
// Author(s) :       Jonathan Roa
//
// Description :     UART TX module w/ configurable baud rates
//                   
//                   4800
//                   9600
//                   19200
//                   57600
//                   115200
//
//                   Assumes 125 MHz clock
//
// Revisions 
//
// Date        Name            REV#        Description 
// ----------  --------------- ----------- -------------------------------------------
// (04/14/24)  Jonathan Roa    1.0         Initial Revision

module uart_tx #
    (
        parameter p_DATA_WIDTH     = 8,
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
        input  wire                        i_rst_n,

        input  wire [p_BAUD_SEL_WIDTH-1:0] i_baud_sel,
        input  wire [p_DATA_WIDTH-1:0]     i_tx_data,
        input  wire                        i_wr_en,
        
        output wire                        o_tx_data,
        output wire                        o_tx_running,
        output wire                        o_tx_done
    );

    wire [p_DATA_WIDTH-1:0] w_tx_data;
    wire                    w_tx_data_parity;

    assign w_tx_data = i_tx_data;

    uart_parity_gen # 
        (
            .p_DATA_WIDTH     (p_DATA_WIDTH)
        )
    inst_parity_gen 
        (
            .i_tx_data        (i_tx_data),
            .o_tx_data_parity (w_tx_data_parity)
        );

endmodule
