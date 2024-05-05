library IEEE;
-- la cpu luego es la que me define que bits son los que entran en la CU

entity ControlUnit is
    Port ( datain   : in  std_logic_vector (19 downto 0);
           status: in std_logic_vector(2 down to 0); -- 3 bits de C Z N en ese orden
           enableA: out std_logic;
           enableB: out std_logic;
           selA: out std_logic_vector(1 downto 0);
           selB: out std_logic_vector(1 downto 0);
           selALU: out std_logic_vector(2 downto 0);
           loadPC: out std_logic;
           w: out std_logic;
           -- De los 20 bits hay que elegir luego (cpu) cuales son para que señal y ademas decir cuales no hacen nada
    );

    end ControlUnit;

architecture Behavioral of ControlUnit is

signal c : STD_LOGIC;
signal z : STD_LOGIC;
signal n : STD_LOGIC;
signal jump_type: STD_LOGIC_VECTOR(3 downto 0);

begin 

enableA <= datain(10);
enableB <= datain(9);
selA <= datain(8 downto 7);
selB <= datain(6 downto 5);
selALU <= datain(4 downto 2);
loadPC <= datain(1);
w <= datain(0);
jump_type <= datain(8 downto 5);

       --Señales de estado ALU/Status
c <= status(0);
z <= status(1);
n <= status(2);



end Behavioral;

with jump_type select
       loadPC <=     '1'                  when "1000",      --JMP
                     z                    when "0100",      --JEQ
                     not z                when "0010",      --JNE
                     not n and not z      when "0001",      --JGT
                     not n                when "1100",      --JGE
                     n                    when "0110",      --JLT
                     n or z               when "0011",      --JLE
                     c                    when "1110",      --JCR
                     '0'                  when others;


