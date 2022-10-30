library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity virtual_display is
    generic (
        G_WIDTH     : natural := 640;
        G_HEIGHT    : natural := 480
    );
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_val : in std_logic;
        i_eol : in std_logic;
        i_eof : in std_logic;
        i_rgb : in std_logic_vector(23 downto 0);
        i_run : in boolean
    );
end virtual_display;


architecture arch of virtual_display is
    
    
    type screen_t is array (
        natural range 0 to G_HEIGHT-1,
        natural range 0 to G_WIDTH-1
    ) of integer;
    
    shared variable v_screen: screen_t;
    
    
    procedure sim_init (
        width  : natural;
        height : natural
    ) is
    begin
        report "VHPIDIRECT sim_init" severity failure;
    end procedure;
    
    attribute foreign of sim_init : procedure is "VHPIDIRECT sim_init";
    
    
    procedure save_screenshot (
        variable ptr : screen_t;
        width        : natural;
        height       : natural;
        id           : integer := 0
    ) is
    begin
        report "VHPIDIRECT save_screenshot" severity failure;
    end procedure;
    
    attribute foreign of save_screenshot : procedure is "VHPIDIRECT save_screenshot";
    
    
    procedure sim_cleanup is
    begin
        report "VHPIDIRECT sim_cleanup" severity failure;
    end procedure;
    
    attribute foreign of sim_cleanup : procedure is "VHPIDIRECT sim_cleanup";
    
    
    constant c_width  : integer := v_screen'length(2);
    constant c_height : integer := v_screen'length(1);
    
    signal s_col_reg : natural;
    signal s_row_reg : natural;
    signal s_frm_reg : natural;
    
begin
    
    
    process (i_clk, i_rst)
    begin
        if (i_rst = '1') then
            s_col_reg <= 0;
            s_row_reg <= 0;
            s_frm_reg <= 0;
        elsif (rising_edge(i_clk)) then
            assert s_col_reg < c_width report "Unexpected value: s_col_reg = " &
                integer'image(s_col_reg) & " should never be equal to or exceed c_width = " &
                integer'image(c_width);
            assert s_row_reg < c_height report "Unexpected value: s_row_reg = " &
                integer'image(s_row_reg) & " should never be equal to or exceed c_height = " &
                integer'image(c_height);
            if (i_val = '1') then
                s_col_reg <= s_col_reg + 1;
                v_screen(s_row_reg, s_col_reg) := to_integer(unsigned(i_rgb));
                if (i_eol = '1') then
                    s_col_reg <= 0;
                    s_row_reg <= s_row_reg + 1;
                end if;
                if (i_eof = '1') then
                    s_row_reg <= 0;
                    s_frm_reg <= s_frm_reg + 1;
                    save_screenshot(
                        v_screen,
                        c_width,
                        c_height,
                        s_frm_reg
                    );
                end if;
            end if;
        end if;
    end process;
    
    process
    begin
        sim_init(G_WIDTH, G_HEIGHT);
        wait until (i_run = false);
        sim_cleanup;
    end process;
    
    
end architecture;

