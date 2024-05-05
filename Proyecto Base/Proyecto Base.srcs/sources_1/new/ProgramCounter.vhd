library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ProgramCounter is

    Port ( clock : in STD_LOGIC;
           count_in : in STD_LOGIC_VECTOR (11 downto 0);
           count_out : inout STD_LOGIC_VECTOR (11 downto 0);
           load_PC : in STD_LOGIC;
           clear : in STD_LOGIC ); 
end ProgramCounter;

architecture Behavioral of ProgramCounter is


begin



end Behavioral;
