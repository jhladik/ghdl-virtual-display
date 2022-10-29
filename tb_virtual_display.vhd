library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_virtual_display is
end tb_virtual_display;


architecture tb of tb_virtual_display is
    
    
begin
    
    
    inst_virtual_monitor : entity work.virtual_display
    generic map (
        G_WIDTH  => 640,
        G_HEIGHT => 480
    );
    
    
end architecture;
