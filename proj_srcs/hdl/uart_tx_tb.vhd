-- File :            uart_tx_tb.vhd
-- Title :           uart_tx_tb
-- 
-- Author(s) :       Jonathan Roa
-- 
-- Description :     Testbench module for UART TX module
-- 
-- Revisions 
-- 
-- Date        Name            REV#        Description 
-- ----------  --------------- ----------- -------------------------------------------
-- (04/15/24)  Jonathan Roa    1.0         Initial Revision

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx_tb is
end uart_tx_tb;

architecture uart_tx_tb_arch of uart_tx_tb is

    component uart_tx is
        generic (
            p_DATA_WIDTH     : integer := 8;
            p_BAUD_CTR_WIDTH : integer := 16;
            p_BAUD_SEL_WIDTH : integer := 3;

            -- Baud counter rollover n = (baud_period/clk_period)
            p_BAUD_4800      : integer := 26042;
            p_BAUD_9600      : integer := 13021;
            p_BAUD_19200     : integer := 6511;
            p_BAUD_57600     : integer := 2171;
            p_BAUD_115200    : integer := 1086
        );
        port (
            i_clk            : in std_logic;
            i_rst_n          : in std_logic;

            i_baud_sel       : in std_logic_vector(p_BAUD_SEL_WIDTH-1 downto 0);
            i_tx_data        : in std_logic_vector(p_DATA_WIDTH-1 downto 0);
            i_wr_en          : in std_logic;
            
            o_tx_data        : out std_logic;
            o_tx_running     : out std_logic;
            o_tx_done        : out std_logic
        );
    end component;

    constant c_CLK_PERIOD       : time    := 8ns;
    constant c_STIM_CNT         : integer := 5;
    constant c_DATA_WIDTH       : integer := 8;
    constant c_BAUD_SEL_WIDTH   : integer := 3;

    type t_DATA_ARRAY     is array (integer range <>) of std_logic_vector (c_DATA_WIDTH-1 downto 0);
    type t_BAUD_SEL_ARRAY is array (integer range <>) of std_logic_vector (c_BAUD_SEL_WIDTH-1 downto 0);
    signal v_data_stim      : t_DATA_ARRAY (0 to c_STIM_CNT-1) := ( x"AA",
                                                                    x"55",
                                                                    x"01",
                                                                    x"77",
                                                                    x"BA" );

    signal v_baud_sel_stim  : t_BAUD_SEL_ARRAY (0 to c_STIM_CNT-1) := ( "000",
                                                                        "001",
                                                                        "010",
                                                                        "011",
                                                                        "100" );

    signal i_clk_tb            : std_logic := '0';
    signal i_rst_n_tb          : std_logic;
    signal i_baud_sel_tb       : std_logic_vector(c_BAUD_SEL_WIDTH-1 downto 0);
    signal i_tx_data_tb        : std_logic_vector(c_DATA_WIDTH-1 downto 0);
    signal i_wr_en_tb          : std_logic := '0';
    signal o_tx_data_tb        : std_logic;
    signal o_tx_running_tb     : std_logic;
    signal o_tx_done_tb        : std_logic;

begin

    UUT: uart_tx
        generic map (
            p_DATA_WIDTH     => 8,
            p_BAUD_CTR_WIDTH => 16,
            p_BAUD_SEL_WIDTH => 3,

            -- Baud counter rollover n = (baud_period/clk_period)
            p_BAUD_4800      => 26042,
            p_BAUD_9600      => 13021,
            p_BAUD_19200     => 6511,
            p_BAUD_57600     => 2171,
            p_BAUD_115200    => 1086
        )
        port map (
            i_clk            => i_clk_tb,
            i_rst_n          => i_rst_n_tb,

            i_baud_sel       => i_baud_sel_tb,
            i_tx_data        => i_tx_data_tb,
            i_wr_en          => i_wr_en_tb,

            o_tx_data        => o_tx_data_tb,
            o_tx_running     => o_tx_running_tb,
            o_tx_done        => o_tx_done_tb
        );

    -- Assert a 5-cycle reset 10 cycles after start of sim
    i_clk_tb   <= not i_clk_tb after c_CLK_PERIOD/2;
    i_rst_n_tb <= '1', '0' after c_CLK_PERIOD * 10, '1' after c_CLK_PERIOD * 15;

    -- Stimulus generator (native Vivado simulator doesn't support var tracing)
    input_stim: process
    begin

        -- Select TX data
        i_tx_data_tb  <= v_data_stim(0); 
        -- i_tx_data_tb  <= v_data_stim(1); 
        -- i_tx_data_tb  <= v_data_stim(2); 
        -- i_tx_data_tb  <= v_data_stim(3); 
        -- i_tx_data_tb  <= v_data_stim(4); 
        
        -- Select baud rate
        i_baud_sel_tb <= v_baud_sel_stim(0);
        -- i_baud_sel_tb <= v_baud_sel_stim(1);
        -- i_baud_sel_tb <= v_baud_sel_stim(2);
        -- i_baud_sel_tb <= v_baud_sel_stim(3);
        -- i_baud_sel_tb <= v_baud_sel_stim(4);

        -- Start TX transaction by strobing write enable
        wait for c_CLK_PERIOD/2;
        wait for c_CLK_PERIOD * 100; 
        i_wr_en_tb    <= '1', '0' after c_CLK_PERIOD*2;
        wait; 

    end process input_stim;

end uart_tx_tb_arch;
