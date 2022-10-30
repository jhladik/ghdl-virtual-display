library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity timing_generator is
    generic (
        G_HACTIVE : natural := 640;
        G_HBLANK  : natural := 160;
        G_VACTIVE : natural := 480;
        G_VBLANK  : natural :=  45
    );
    port (
        i_clk : in  std_logic;
        i_rst : in  std_logic;
        o_val : out std_logic;
        o_eol : out std_logic;
        o_eof : out std_logic
    );
end timing_generator;


architecture arch of timing_generator is
    
    
    signal s_col_next, s_col_reg : unsigned(15 downto 0);
    signal s_row_next, s_row_reg : unsigned(15 downto 0);
    signal s_val_next, s_val_reg : std_logic;
    signal s_eol_next, s_eol_reg : std_logic;
    signal s_eof_next, s_eof_reg : std_logic;
    
    
begin
    
    
    s_col_next <= (others => '0') when (s_col_reg = (G_HBLANK + G_HACTIVE - 1)) else
                  s_col_reg + 1;
    
    s_row_next <= (others => '0') when ((s_col_reg = (G_HBLANK + G_HACTIVE - 1))  and
                                        (s_row_reg = (G_VBLANK + G_VACTIVE - 1))) else
                  s_row_reg + 1   when  (s_col_reg = (G_HBLANK + G_HACTIVE - 1))  else
                  s_row_reg;
    
    P_COUNTERS_FF: process (i_clk, i_rst)
    begin
        if (i_rst = '1') then
            s_col_reg <= (others => '0');
            s_row_reg <= (others => '0');
        elsif (rising_edge(i_clk)) then
            s_col_reg <= s_col_next;
            s_row_reg <= s_row_next;
        end if;
    end process;
    
    
    s_val_next <= '1' when ((s_col_reg > (G_HBLANK - 1))  and 
                            (s_row_reg > (G_VBLANK - 1))) else
                  '0';
    
    s_eol_next <= '1' when ((s_col_reg = (G_HBLANK + G_HACTIVE - 1)) and 
                            (s_row_reg > (G_VBLANK - 1)))            else
                  '0';
    
    s_eof_next <= '1' when ((s_col_reg = (G_HBLANK + G_HACTIVE - 1))  and
                            (s_row_reg = (G_VBLANK + G_VACTIVE - 1))) else '0';
    
    P_OUTPUTS_FF: process (i_clk, i_rst)
    begin
        if (i_rst = '1') then
            s_val_reg <= '0';
            s_eol_reg <= '0';
            s_eof_reg <= '0';
        elsif (rising_edge(i_clk)) then
            s_val_reg <= s_val_next;
            s_eol_reg <= s_eol_next;
            s_eof_reg <= s_eof_next;
        end if;
    end process;
    
    -- Assign outputs
    o_val <= s_val_reg;
    o_eol <= s_eol_reg;
    o_eof <= s_eof_reg;
    
    
end architecture;

