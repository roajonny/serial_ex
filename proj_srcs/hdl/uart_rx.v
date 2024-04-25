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

    localparam p_START_STOP_PARITY = 3;
    localparam p_PACKET_WIDTH      = p_DATA_WIDTH + p_START_STOP_PARITY;

    localparam s_IDLE            = 2'b00;
    localparam s_RX_SAMPLE_FIRST = 2'b01;
    localparam s_RX_SAMPLE_REST  = 2'b10;
    localparam s_RX_DONE         = 2'b11;

    reg  [p_PACKET_WIDTH-1:0]   r_rx_shifter;

    reg  [1:0]                  r_RX_STATE;
    reg  [1:0]                  r_RX_STATE_next;

    reg  [p_BAUD_CTR_WIDTH-1:0] r_baud_ctr;

    reg  [1:0]                  r_si_pipe;
    wire                        w_start_shift;
    wire                        w_rx_shift_done;
    wire                        w_baud_ctr_en;
    wire                        w_baud_pulse;
    reg                         r_baud_ctr_en;
    reg                         r_rx_running;
    reg                         r_rx_done;
    reg                         r_sample_first_ref_sel;
    wire                        w_sample_first_ref_sel;
    wire                        w_first_sampled;
    reg                         r_first_sampled;
    
    reg  [p_BAUD_CTR_WIDTH-1:0] r_baud_ctr_ref;
    reg  [p_BAUD_CTR_WIDTH-1:0] r_baud_ctr_val;
    wire                        w_packet_rcvd;
    reg  [p_PACKET_WIDTH-1:0]   r_rx_bit_ctr;

    wire [p_DATA_WIDTH-1:0]     w_rx_data;

    // Synchronizes the serial input
    assign w_start_shift = ~r_si_pipe[0];
    always @ (posedge i_clk) begin
        if (!i_rst_n) begin 
            r_si_pipe    <= {2{1'b1}};
        end else begin
            r_si_pipe[1] <= i_tx_data;
            r_si_pipe[0] <= r_si_pipe[1];
        end
    end

    // Data is shifted in on sampling pulse
    always @ (posedge i_clk) begin
        if (!i_rst_n) begin
            r_rx_shifter <= {p_PACKET_WIDTH{1'b1}};
        end else if (w_baud_pulse) begin
            r_rx_shifter <= {i_tx_data, r_rx_shifter[p_PACKET_WIDTH-1:1]};
        end else begin
            r_rx_shifter <= r_rx_shifter;
        end
    end

    // Indicate to the FSM when the first bit is sampled
    assign w_first_sampled = r_first_sampled;
    always @ (posedge i_clk) begin
        if (!i_rst_n) begin
            r_first_sampled <= 1'b0;
        end else if (w_sample_first_ref_sel && w_baud_pulse) begin
            r_first_sampled <= 1'b1;
        end else begin
            r_first_sampled <= 1'b0;
        end
    end

    // Counter indicates when packet is received 
    assign w_packet_rcvd = (r_rx_bit_ctr == p_PACKET_WIDTH) ? 1'b1 : 1'b0;
    assign w_rx_data     = r_rx_shifter[p_DATA_WIDTH:1];
    assign o_rx_data     = w_rx_data;
    always @ (posedge i_clk) begin
        if (!i_rst_n) begin
            r_rx_bit_ctr <= {p_PACKET_WIDTH{1'b0}};
        end else if (w_baud_ctr_en) begin
            if (w_baud_pulse) begin
                r_rx_bit_ctr <= r_rx_bit_ctr + 1;
            end else begin
                r_rx_bit_ctr <= r_rx_bit_ctr;
            end
        end else begin
            r_rx_bit_ctr <= {p_PACKET_WIDTH{1'b0}};
        end
    end

    // Counter generates the sampling pulse
    assign w_baud_pulse = (r_baud_ctr == r_baud_ctr_ref) ? 1'b1 : 1'b0;
    always @ (posedge i_clk) begin
        if (!i_rst_n || w_baud_pulse) begin
            r_baud_ctr <= {p_BAUD_CTR_WIDTH{1'b0}};
        end else if (w_baud_ctr_en) begin
            r_baud_ctr <= r_baud_ctr + 1;
        end else begin
            r_baud_ctr <= {p_BAUD_CTR_WIDTH{1'b0}};
        end
    end
   
    // Registers the value for the baud counter
    always @ (posedge i_clk) begin
        if (!i_rst_n) begin
            r_baud_ctr_val <= {p_BAUD_CTR_WIDTH{1'b0}};
        end else begin
            case (i_baud_sel)
                3'b001  : r_baud_ctr_val = p_BAUD_4800;
                3'b010  : r_baud_ctr_val = p_BAUD_19200;
                3'b011  : r_baud_ctr_val = p_BAUD_57600;
                3'b100  : r_baud_ctr_val = p_BAUD_115200;
                default : r_baud_ctr_val = p_BAUD_9600;
            endcase
        end
    end

    // Generates reference for ctr comparison to implement center-sampling
    always @ (posedge i_clk) begin
        if (!i_rst_n) begin
            r_baud_ctr_ref <= {p_BAUD_CTR_WIDTH{1'b0}};
        end else if (w_sample_first_ref_sel) begin
            r_baud_ctr_ref <= r_baud_ctr_val >> 1;
        end else begin
            r_baud_ctr_ref <= r_baud_ctr_val;
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

    assign o_rx_running           = r_rx_running;
    assign o_rx_done              = r_rx_done;
    assign w_baud_ctr_en          = r_baud_ctr_en;
    assign w_sample_first_ref_sel = r_sample_first_ref_sel;
    always @ (*) begin
        case (r_RX_STATE)
            s_IDLE: begin
                r_rx_running           <= 1'b0;
                r_rx_done              <= 1'b0;
                r_baud_ctr_en          <= 1'b0;
                r_sample_first_ref_sel <= 1'b0;
                if (w_start_shift) begin
                    r_RX_STATE_next <= s_RX_SAMPLE_FIRST;
                end else begin
                    r_RX_STATE_next <= s_IDLE;
                end
            end
            s_RX_SAMPLE_FIRST: begin
                r_rx_running           <= 1'b1;
                r_rx_done              <= 1'b0;
                r_baud_ctr_en          <= 1'b1;
                r_sample_first_ref_sel <= 1'b1;
                if (w_first_sampled) begin
                    r_RX_STATE_next <= s_RX_SAMPLE_REST;
                end else begin
                    r_RX_STATE_next <= s_RX_SAMPLE_FIRST;
                end
            end
            s_RX_SAMPLE_REST: begin
                r_rx_running           <= 1'b1;
                r_rx_done              <= 1'b0;
                r_baud_ctr_en          <= 1'b1;
                r_sample_first_ref_sel <= 1'b0;
                if (w_packet_rcvd) begin
                    r_RX_STATE_next <= s_RX_DONE;
                end else begin
                    r_RX_STATE_next <= s_RX_SAMPLE_REST;
                end 
            end
            s_RX_DONE: begin
                r_rx_running           <= 1'b0;
                r_rx_done              <= 1'b1;
                r_baud_ctr_en          <= 1'b0;
                r_sample_first_ref_sel <= 1'b0;
                r_RX_STATE_next <= s_IDLE;
            end
            default: begin
                r_rx_running           <= 1'b0;
                r_rx_done              <= 1'b0;
                r_baud_ctr_en          <= 1'b0;
                r_sample_first_ref_sel <= 1'b0;
                r_RX_STATE_next <= s_IDLE;
            end
        endcase
    end

endmodule
