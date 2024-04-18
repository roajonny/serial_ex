`timescale 1ns / 1ps

// File :            uart_rx.v
// Title :           uart_rx
//
// Author(s) :       Jonathan Roa
//
// Description :     UART RX - LSB-first, programmable baud rate and data width
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
// (04/17/24)  Jonathan Roa    1.0         Initial Revision

module uart_rx #
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
        input  wire                        i_rst_n,

        input  wire [p_BAUD_SEL_WIDTH-1:0] i_baud_sel,
        input  wire                        i_tx_data,

        output wire [p_DATA_WIDTH-1:0]     o_rx_data,
        output wire                        o_rx_running,
        output wire                        o_rx_done
    );

    reg  [1:0]           r_si_pipe;
    wire                 w_start_shift;
    
    // Start shift sequence after detecting start bit
    assign w_start_shift = ~r_si_pipe[1] & r_si_pipe[0];
    always @ (posedge i_clk)
    begin
        if (!i_rst_n) begin 
            r_si_pipe    <= {2{1'b1}};
        end else begin
            r_si_pipe[1] <= i_tx_data;
            r_si_pipe[0] <= r_si_pipe[1];
        end
    end

endmodule
