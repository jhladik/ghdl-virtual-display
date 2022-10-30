library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_virtual_display is
    generic (
        G_HACTIVE : natural := 160;
        G_HBLANK  : natural :=  40;
        G_VACTIVE : natural := 120;
        G_VBLANK  : natural :=  11;
        G_FRAMES  : natural :=  16
    );
end tb_virtual_display;


architecture tb of tb_virtual_display is
    
    
    signal s_clk : std_logic := '1';
    signal s_rst : std_logic := '1';
    signal s_val : std_logic;
    signal s_eol : std_logic;
    signal s_eof : std_logic;
    signal s_rgb : std_logic_vector(23 downto 0);
    signal s_run : boolean := true;
    
    constant c_clk_per : time := 10 ns; 
    
    procedure wait_rising_edges(signal i_clk: std_logic; n: natural) is
    begin
        for i in 0 to n-1 loop
            wait until rising_edge(i_clk);
        end loop;
    end procedure;
    
    signal s_col_reg : unsigned(15 downto 0);
    signal s_row_reg : unsigned(15 downto 0);
    signal s_frm_reg : unsigned(15 downto 0);
    
    
begin
    
    
    -- Generate clock
    s_clk <= not s_clk after (c_clk_per / 2) when (s_run = true) else '0';
    
    -- Instantiate DUT
    inst_virtual_monitor : entity work.virtual_display
    generic map (
        G_WIDTH  => G_HACTIVE,
        G_HEIGHT => G_VACTIVE
    )
    port map (
        i_clk => s_clk,
        i_rst => s_rst,
        i_val => s_val,
        i_eol => s_eol,
        i_eof => s_eof,
        i_rgb => s_rgb,
        i_run => s_run
    );
    
    -- Instantiate timing generator
    inst_timing_generator : entity work.timing_generator
    generic map (
        G_HACTIVE => G_HACTIVE,
        G_HBLANK  => G_HBLANK,
        G_VACTIVE => G_VACTIVE,
        G_VBLANK  => G_VBLANK
    )
    port map (
        i_clk => s_clk,
        i_rst => s_rst,
        o_val => s_val,
        o_eol => s_eol,
        o_eof => s_eof
    );
    
    
    -- Generate an interesting pattern
    process (s_clk, s_rst)
    begin
        if (s_rst = '1') then
            s_col_reg <= (others => '0');
            s_row_reg <= (others => '0');
            s_frm_reg <= (others => '0');
        elsif (rising_edge(s_clk)) then
            if (s_val = '1') then
                s_col_reg <= s_col_reg + 1;
                if (s_eol = '1') then
                    s_col_reg <= (others => '0');
                    s_row_reg <= s_row_reg + 1;
                end if;
                if (s_eof = '1') then
                    s_row_reg <= (others => '0');
                    s_frm_reg <= s_frm_reg + 1;
                end if;
            end if;
        end if;
    end process;
    
    s_rgb <= std_logic_vector(s_col_reg(7 downto 0)) &
             std_logic_vector(s_row_reg(7 downto 0)) &
             std_logic_vector(s_frm_reg(3 downto 0) & "0000");
    
    
    -- Generate stimuli
    process
    begin
        -- Set initial values
        s_rst <= '1';
        
        -- Generate reset pulse
        s_rst <= '1';
        wait_rising_edges(s_clk, 4);
        s_rst <= '0';
        
        -- Wait for a while to see the frames
        wait_rising_edges(s_clk, (G_HACTIVE+G_HBLANK)*(G_VACTIVE+G_VBLANK)*G_FRAMES+10);
        s_run <= false;
        
        wait;
    end process;
    
    
end architecture;

