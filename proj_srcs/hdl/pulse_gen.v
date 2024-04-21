`timescale 1ns / 1ps

// File :            pulse_gen.v
// Title :           pulse_gen
//
// Author(s) :       Jonathan Roa
//
// Description :     Single pulse generator
//
// Revisions 
//
// Date        Name            REV#        Description 
// ----------  --------------- ----------- -------------------------------------------
// (04/19/24)  Jonathan Roa    1.0         Initial Revision

module pulse_gen 
    (
        input  wire     i_clk,
        input  wire     i_rst_n,

        input  wire     i_trigger,
        output wire     o_pulse
    );

    localparam s_IDLE      = 2'b00;
    localparam s_GEN_PULSE = 2'b01;
    localparam s_DONE      = 2'b10;

    reg  [1:0]                  r_STATE;
    reg  [1:0]                  r_STATE_next;

    reg  [1:0]                  r_trig_pipe;
    reg                         r_pulse;

    wire                        w_start_pulse_gen;

    // FSM initiated by rising-edge to prevent multiple pulses from being gen'd
    // when trigger is held indefinitely
    assign w_start_pulse_gen = r_trig_pipe[1] && ~r_trig_pipe[0];
    always @ (posedge i_clk) begin
        if (!i_rst_n) begin
            r_trig_pipe <= 2'b0;
        end else begin
            r_trig_pipe[1] <= i_trigger;
            r_trig_pipe[0] <= r_trig_pipe[1];
        end
    end
    
    // 2-block FSM controls baud + shift counters, and UART state
    always @ (posedge i_clk) begin
        if (!i_rst_n) begin
            r_STATE <= s_IDLE;
        end else begin
            r_STATE <= r_STATE_next;
        end
    end

    assign o_pulse = r_pulse;
    always @ (*) begin
        case (r_STATE)
            s_IDLE: begin
                r_pulse <= 1'b0;
                if (w_start_pulse_gen) begin
                    r_STATE_next <= s_GEN_PULSE;
                end else begin
                    r_STATE_next <= s_IDLE;
                end
            end
            s_GEN_PULSE: begin
                r_pulse <= 1'b1;
                r_STATE_next <= s_DONE;
            end
            s_DONE: begin
                r_pulse <= 1'b0;
                r_STATE_next <= s_IDLE;
            end
            default: begin
                r_pulse <= 1'b0;
                r_STATE_next <= s_IDLE;
            end
        endcase
    end

endmodule
