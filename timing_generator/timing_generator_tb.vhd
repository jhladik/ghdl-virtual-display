library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity timing_generator_tb is
end timing_generator_tb;


architecture tb of timing_generator_tb is
    
    
    signal s_clk : std_logic := '1';
    signal s_rst : std_logic := '1';
    signal s_val : std_logic;
    signal s_eol : std_logic;
    signal s_eof : std_logic;
    signal s_run : boolean := true;
    
    constant c_clk_per : time := 10 ns; 
    
    procedure wait_rising_edges(signal i_clk: std_logic; n: natural) is
    begin
        for i in 0 to n-1 loop
            wait until rising_edge(i_clk);
        end loop;
    end procedure;
    
    
begin
    
    -- Generate clock
    s_clk <= not s_clk after (c_clk_per / 2) when (s_run = true) else '0';
    
    -- Instantiate DUT
    inst_timing_generator : entity work.timing_generator
    generic map (
        G_HACTIVE => 8,
        G_HBLANK  => 4,
        G_VACTIVE => 6,
        G_VBLANK  => 3
    )
    port map (
        i_clk => s_clk,
        i_rst => s_rst,
        o_val => s_val,
        o_eol => s_eol,
        o_eof => s_eof
    );
    
    -- Generate stimuli
    process
    begin
        -- Set initial values
        s_rst <= '1';
        
        -- Generate reset pulse
        s_rst <= '1';
        wait_rising_edges(s_clk, 4);
        s_rst <= '0';
        
        -- Wait for a while to see the waveforms
        wait_rising_edges(s_clk, (3*(8+4)*(6+3)+12));
        s_run <= false;
        
        wait;
    end process;
    
    
end architecture;

