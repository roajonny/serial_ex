`timescale 1ns / 1ps

// File :            uart_tx.v
// Title :           uart_tx
//
// Author(s) :       Jonathan Roa
//
// Description :     LSB-first UART TX module w/ configurable baud rates
//                   
//                   4800   : baud select 001
//                   9600   : default
//                   19200  : baud select 010
//                   57600  : baud select 011
//                   115200 : baud select 100
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
        input  wire [p_DATA_WIDTH-1:0]     i_tx_data,
        input  wire                        i_wr_en,
        
        output wire                        o_tx_data,
        output wire                        o_tx_running,
        output wire                        o_tx_done
    );

    localparam p_STOP_START_PARITY = 3;
    localparam p_STOP_BIT          = 1'b1;
    localparam p_START_BIT         = 1'b0;
    localparam p_PACKET_WIDTH      = p_DATA_WIDTH + p_STOP_START_PARITY; 

    wire [p_DATA_WIDTH-1:0]     w_tx_data;
    wire                        w_tx_data_parity;
    wire                        w_baud_pulse;
    reg  [p_BAUD_CTR_WIDTH-1:0] r_baud_ctr_ref;

    reg  [p_PACKET_WIDTH-1:0]   r_tx_shift;
    reg  [p_BAUD_CTR_WIDTH-1:0] r_baud_ctr;

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

    // Frame packer and shifter, idle-high data line
    assign o_tx_data = r_tx_shift[0];
    always @ (posedge i_clk) begin
        if (!i_rst_n) begin
            r_tx_shift <= {p_PACKET_WIDTH{1'b1}};
        end else if (i_wr_en) begin        // Package the UART TX frame
            r_tx_shift <= {p_STOP_BIT, w_tx_data_parity, w_tx_data, p_START_BIT};
        end else if (w_baud_pulse) begin   // Shift out on baud counter
            r_tx_shift <= {1'b1, r_tx_shift[p_PACKET_WIDTH-1:1]};
        end else begin
            r_tx_shift <= r_tx_shift;
        end
    end 

    // Inputs to baud pulse comparison are synchronous
    assign w_baud_pulse = (r_baud_ctr == r_baud_ctr_ref) ? 1'b1 : 1'b0;

    always @ (posedge i_clk) begin
        if (!i_rst_n || w_baud_pulse) begin
            r_baud_ctr <= {p_BAUD_CTR_WIDTH{1'b0}};
        end else begin
            r_baud_ctr <= r_baud_ctr + 1;
        end
    end

    always @ (posedge i_clk) begin
        if (!i_rst_n) begin
            r_baud_ctr_ref <= {p_BAUD_CTR_WIDTH{1'b0}};
        end else begin
            case (i_baud_sel)
                3'b001  : r_baud_ctr_ref = p_BAUD_4800;
                3'b010  : r_baud_ctr_ref = p_BAUD_19200;
                3'b011  : r_baud_ctr_ref = p_BAUD_57600;
                3'b100  : r_baud_ctr_ref = p_BAUD_115200;
                default : r_baud_ctr_ref = p_BAUD_9600;
            endcase
        end
    end

endmodule
