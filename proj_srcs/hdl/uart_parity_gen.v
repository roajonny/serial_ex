`timescale 1ns / 1ps

// File :            uart_parity_gen.v
// Title :           uart_parity_gen
//
// Author(s) :       Jonathan Roa
//
// Description :     Odd parity generator for UART TX module
//
// Revisions 
//
// Date        Name            REV#        Description 
// ----------  --------------- ----------- -------------------------------------------
// (04/15/24)  Jonathan Roa    1.0         Initial Revision

module uart_parity_gen #
    (
        parameter p_DATA_WIDTH = 8
    )
    (
        input  wire [p_DATA_WIDTH-1:0] i_tx_data,
        output wire                    o_tx_data_parity
    );

    assign o_tx_data_parity = ^i_tx_data;

endmodule
