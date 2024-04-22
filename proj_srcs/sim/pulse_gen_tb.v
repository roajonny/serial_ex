`timescale 1ns / 1ps

// File :            pulse_gen_tb.v
// Title :           pulse_gen_tb
//
// Author(s) :       Jonathan Roa
//
// Description :     Testbench for Single pulse generator
//
// Revisions 
//
// Date        Name            REV#        Description 
// ----------  --------------- ----------- -------------------------------------------
// (04/19/24)  Jonathan Roa    1.0         Initial Revision

module pulse_gen_tb ();

    localparam p_CLK_PERIOD = 8;

    reg  r_clk;
    reg  r_rst_n;
    reg  r_trigger;

    wire w_pulse;

    pulse_gen uut 
        (
            .i_clk        (r_clk),
            .i_rst_n      (r_rst_n),

            .i_trigger    (r_trigger),
            .o_pulse      (w_pulse)
        );

    // Generate the clock
    always begin
        #(p_CLK_PERIOD/2); r_clk <= ~r_clk;
    end

    // Simulation body
    initial begin
        init();          #(p_CLK_PERIOD*5); 
        assert_rst(); 
        assert_trig();   #(p_CLK_PERIOD*5);
        deassert_trig(); #(p_CLK_PERIOD*100);
    end

    // Helper tasks
    task assert_trig(); begin
        r_trigger <= 1'b1;
    end
    endtask

    task deassert_trig (); begin
        r_trigger <= 1'b0;
    end
    endtask

    task assert_rst(); begin
        r_rst_n <= 1'b0; #(p_CLK_PERIOD*5);
        r_rst_n <= 1'b1;
    end
    endtask

    task init(); begin
        r_clk     <= 1'b1;
        r_rst_n   <= 1'b1;
        r_trigger <= 1'b0;
        end
    endtask

endmodule
