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
        parameter p_DATA_WIDTH = 8,
        parameter p_BAUD_SEL_WIDTH = 3
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
endmodule
