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

    reg  [1:0]                  r_trig_pipe;
    wire                        w_pulse;

    assign o_pulse = w_pulse;
    assign w_pulse = r_trig_pipe[1] && ~r_trig_pipe[0];
    always @ (posedge i_clk) begin
        if (!i_rst_n) begin
            r_trig_pipe <= 2'b0;
        end else begin
            r_trig_pipe[1] <= i_trigger;
            r_trig_pipe[0] <= r_trig_pipe[1];
        end
    end
    
endmodule
