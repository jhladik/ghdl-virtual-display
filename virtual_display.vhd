library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity virtual_display is
    generic (
        G_WIDTH  : natural := 640;
        G_HEIGHT : natural := 480
    );
end virtual_display;


architecture arch of virtual_display is
    
    
    type screen_t is array (
        natural range 0 to G_HEIGHT-1,
        natural range 0 to G_WIDTH-1
    ) of integer;
    
    shared variable screen: screen_t;
    
    
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
    
    
    function RGB_to_integer (
        rgb : std_logic_vector(2 downto 0)
    ) return integer is
        variable raw24: std_logic_vector(31 downto 0);
    begin
        raw24 := (
             7 downto  0 => rgb(0),
            15 downto  8 => rgb(1),
            23 downto 16 => rgb(2),
               others    => '0'
        );
        return to_integer(unsigned(raw24));
    end function;
   
   
    constant c_width  : integer := screen'length(2);
    constant c_height : integer := screen'length(1);
    
    
begin
    
    
    process
        variable h, i, j, d_x, d_y: integer;
        constant w : natural := 100;
    begin
        sim_init(G_WIDTH, G_HEIGHT);
        
        for h in 0 to 15 loop
            d_x := h * (c_width-w-1)/15;
            d_y := h * (c_height-w-1)/15;
            
            for j in 0 to c_height-1 loop
                for i in 0 to c_width-1 loop
                    screen(j,i) := 16#FFFF00#;
                end loop;
            end loop;
            
            for j in d_y to d_y+w loop
                for i in d_x to d_x+w loop
                    screen( j, i ) := 16#00FFFF#;
                end loop;
            end loop;
            
            save_screenshot(
                screen,
                c_width,
                c_height,
                h
            );
        end loop;
        
        sim_cleanup;
        wait;
    end process;
    
    
end architecture;

