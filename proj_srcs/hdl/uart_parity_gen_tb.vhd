-- File :            uart_parity_gen_tb.vhd
-- Title :           uart_parity_gen_tb
-- 
-- Author(s) :       Jonathan Roa
-- 
-- Description :     Testbench module for UART TX parity generator
-- 
-- Revisions 
-- 
-- Date        Name            REV#        Description 
-- ----------  --------------- ----------- -------------------------------------------
-- (04/15/24)  Jonathan Roa    1.0         Initial Revision

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_parity_gen_tb is
end uart_parity_gen_tb;

architecture uart_parity_gen_tb_arch of uart_parity_gen_tb is

    component uart_parity_gen is
        generic (
            p_DATA_WIDTH : integer := 8
        );
        port (
            i_tx_data           : in  std_logic_vector(p_DATA_WIDTH-1 downto 0);
            o_tx_data_parity    : out std_logic
        );
    end component;

    constant c_CLK_PERIOD   : time    := 8ns;
    constant c_STIM_CNT     : integer := 5;
    constant c_DATA_WIDTH   : integer := 8;

    type t_VECTOR_ARRAY is array (integer range <>) of std_logic_vector (c_DATA_WIDTH-1 downto 0);
    signal v_stimulus : t_VECTOR_ARRAY (0 to c_STIM_CNT-1) := ( x"AA",
                                                                x"55",
                                                                x"01",
                                                                x"77",
                                                                x"BA" );

    signal w_tx_data        : std_logic_vector(c_DATA_WIDTH-1 downto 0);
    signal w_tx_data_parity : std_logic;

begin

    UUT: uart_parity_gen
        generic map (
            p_DATA_WIDTH => 8
        )
        port map (
            i_tx_data        => w_tx_data,
            o_tx_data_parity => w_tx_data_parity
        );

    -- Stimulus generator (native Vivado simulator doesn't support var tracing)
    input_stim: process
        -- variable stim_index : integer range 0 to 7 := 0;
    begin

        -- Test 1
        w_tx_data <= v_stimulus(0); 
        wait for c_CLK_PERIOD * 100; 
        -- stim_index := stim_index + 1;

        -- Test 2
        w_tx_data <= v_stimulus(1); 
        wait for c_CLK_PERIOD * 100; 
        -- stim_index := stim_index + 1;

        -- Test 3
        w_tx_data <= v_stimulus(2); 
        wait for c_CLK_PERIOD * 100; 
        -- stim_index := stim_index + 1;

        -- Test 4
        w_tx_data <= v_stimulus(3); 
        wait for c_CLK_PERIOD * 100; 
        -- stim_index := stim_index + 1;

        -- Test 5
        w_tx_data <= v_stimulus(4); 
        wait;

    end process input_stim;

end uart_parity_gen_tb_arch;
