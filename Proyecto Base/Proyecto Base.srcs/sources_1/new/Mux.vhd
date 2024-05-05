library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
USE IEEE.NUMERIC_STD.ALL;

entity Mux is
    Port(
        datain_0 : in STD_LOGIC_VECTOR(15 downto 0); 
        datain_1 : in STD_LOGIC_VECTOR(15 downto 0);
        datain_2 : in STD_LOGIC_VECTOR(15 downto 0);
        datain_3 : in STD_LOGIC_VECTOR(15 downto 0);
        sel : in STD_LOGIC_VECTOR(1 downto 0);
        dataout : out STD_LOGIC_VECTOR(15 downto 0));
end Mux;

architecture Behavioral of Mux is

begin

    with sel select 
        dataout <= datain_0 when "00", -- este será 0 en A y en B
                   datain_1 when "01", -- este en A es 1, RegB en B
                   datain_2 when "10", -- en A es Null, en B es ram_dataout
                   datain_3 when "11", -- en A es RegA, en B es LitMB
                   '0' when others;

end Behavioral; 
