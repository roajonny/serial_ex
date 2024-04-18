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

    localparam s_IDLE       = 2'b00;
    localparam s_RX_RUNNING = 2'b01;
    localparam s_RX_DONE    = 2'b10;

    reg  [1:0]          r_RX_STATE;
    reg  [1:0]          r_RX_STATE_next;

    reg  [1:0]          r_si_pipe;
    wire                w_start_shift;
    wire                w_rx_shift_done;
    wire                w_baud_ctr_en;
    reg                 r_baud_ctr_en;
    reg                 r_rx_running;
    reg                 r_rx_done;
    
    // Shift sequence kicks off when the start bit is detected
    assign w_start_shift = ~r_si_pipe[1] & r_si_pipe[0];
    always @ (posedge i_clk) begin
        if (!i_rst_n) begin 
            r_si_pipe    <= {2{1'b1}};
        end else begin
            r_si_pipe[1] <= i_tx_data;
            r_si_pipe[0] <= r_si_pipe[1];
        end
    end
    
    // 2-block FSM controls baud + shift counters, and UART state
    always @ (posedge i_clk) begin
        if (!i_rst_n) begin
            r_RX_STATE <= s_IDLE;
        end else begin
            r_RX_STATE <= r_RX_STATE_next;
        end
    end

    assign w_baud_ctr_en = r_baud_ctr_en;
    assign o_rx_running  = r_rx_running;
    assign o_rx_done     = r_rx_done;
    always @ (*) begin
        case (r_RX_STATE)
            s_IDLE: begin
                r_rx_running  <= 1'b0;
                r_rx_done     <= 1'b0;
                r_baud_ctr_en <= 1'b0;
                if (w_start_shift) begin
                    r_RX_STATE_next <= s_RX_RUNNING;
                end else begin
                    r_RX_STATE_next <= s_IDLE;
                end
            end
            s_RX_RUNNING: begin
                r_rx_running  <= 1'b1;
                r_rx_done     <= 1'b0;
                r_baud_ctr_en <= 1'b1;
                if (w_rx_shift_done) begin
                    r_RX_STATE_next <= s_RX_DONE;
                end else begin
                    r_RX_STATE_next <= s_RX_RUNNING;
                end 
            end
            s_RX_DONE: begin
                r_rx_running  <= 1'b0;
                r_rx_done     <= 1'b1;
                r_baud_ctr_en <= 1'b0;
                r_RX_STATE_next <= s_IDLE;
            end
            default: begin
                r_rx_running  <= 1'b0;
                r_rx_done     <= 1'b0;
                r_baud_ctr_en <= 1'b0;
                r_RX_STATE_next <= s_IDLE;
            end
        endcase
    end

endmodule
