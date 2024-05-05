library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


entity CPU is
    Port (
           clock : in STD_LOGIC;
           clear : in STD_LOGIC;
           ram_address : out STD_LOGIC_VECTOR (11 downto 0);
           ram_datain : out STD_LOGIC_VECTOR (15 downto 0);
           ram_dataout : in STD_LOGIC_VECTOR (15 downto 0);
           ram_write : out STD_LOGIC;
           rom_address : out STD_LOGIC_VECTOR (11 downto 0);
           rom_dataout : in STD_LOGIC_VECTOR (35 downto 0);
           dis : out STD_LOGIC_VECTOR (15 downto 0));
end CPU;

architecture Behavioral of CPU is
component Reg is
    Port ( clock    : in  std_logic;                        -- Señal del clock (reducido).
           clear    : in  std_logic;                        -- Señal de reset.
           load     : in  std_logic;                        -- Señal de carga.
           up       : in  std_logic;                        -- Señal de subida.
           down     : in  std_logic;                        -- Señal de bajada.
           datain   : in  std_logic_vector (15 downto 0);   -- Señales de entrada de datos.
           dataout  : out std_logic_vector (15 downto 0));  -- Señales de salida de datos.
end component;



component Mux is
    Port(
        datain_0 : in STD_LOGIC_VECTOR(15 downto 0); 
        datain_1 : in STD_LOGIC_VECTOR(15 downto 0);
        datain_2 : in STD_LOGIC_VECTOR(15 downto 0);
        datain_3 : in STD_LOGIC_VECTOR(15 downto 0);
        sel : in STD_LOGIC_VECTOR(1 downto 0);
        dataout : out STD_LOGIC_VECTOR(15 downto 0));
end component;


component ALU is
    Port ( a        : in  std_logic_vector (7 downto 0);   -- Primer operando.
           b        : in  std_logic_vector (7 downto 0);   -- Segundo operando.
           sop      : in  std_logic_vector (2 downto 0);   -- Selector de la operación.
           c        : out std_logic;                       -- Señal de 'carry'.
           z        : out std_logic;                       -- Señal de 'zero'.
           n        : out std_logic;                       -- Señal de 'nagative'.
           result   : out std_logic_vector (7 downto 0));  -- Resultado de la operación.
end component;

component Status 
    Port ( c     : in STD_LOGIC;
           z     : in STD_LOGIC;
           n     : in STD_LOGIC;
           clock : in std_logic;
           out_status : out STD_LOGIC_VECTOR (2 downto 0));
end component;

component ProgramCounter is

    Port ( clock : in STD_LOGIC;
           count_in : in STD_LOGIC_VECTOR (11 downto 0);
           count_out : inout STD_LOGIC_VECTOR (11 downto 0);
           load_PC : in STD_LOGIC;
           clear : in STD_LOGIC ); 
end component;

component ControlUnit is
    Port ( datain   : in  std_logic_vector (19 downto 0);
           status: in std_logic_vector(2 downto 0);
           enableA: out std_logic;
           enableB: out std_logic;
           selA: out std_logic_vector(1 downto 0);
           selB: out std_logic_vector(1 downto 0);
           selALU: out std_logic_vector(2 downto 0);
           loadPC: out std_logic;
           w: out std_logic);
end component;

component Adder is
  Port ( a  : in  std_logic_vector (7 downto 0);
           b  : in  std_logic_vector (7 downto 0);
           ci : in  std_logic;
           s  : out std_logic_vector (7 downto 0);
           co : out std_logic);
end component;

signal enableA          : std_logic; 
signal enableB          : std_logic;                    
signal regA_out         : std_logic_vector(15 downto 0); 
signal muxA_out         : std_logic_vector(15 downto 0); 
signal selA             : std_logic_vector(1 downto 0);  
signal regB_out         : std_logic_vector(15 downto 0);
signal muxB_out         : std_logic_vector(15 downto 0); 


signal selB             : std_logic_vector(1 downto 0);  
signal selALU           : std_logic_vector(2 downto 0); 
signal alu_result           : std_logic_vector(15 downto 0);  

signal up_RegA          : std_logic := '0';
signal down_RegA        : std_logic := '0';

signal next_pc_value : STD_LOGIC_VECTOR(11 downto 0);
signal load_pc        : std_logic := '0';
signal pc_dataout       : std_logic_vector(11 downto 0); 


signal c                : std_logic;                     
signal z                : std_logic;                      
signal n                : std_logic;                      
signal status_out       : std_logic_vector(2 downto 0);
signal write_ram            : std_logic; 

signal rom_dataout_muxerB : std_logic_vector(35 downto 20); --señal de los 36 bits

-- faltan señales
begin
-- Instancias


inst_RegA: Reg port map(
    clock       => clock,
    clear       => clear,
    load        => enableA,
    up          => up_RegA,
    down        => down_RegA,
    datain      => alu_result,  
    dataout     => regA_out
    );

inst_RegB: Reg port map(
    clock       => clock,
    clear       => clear,
    load        => enableB,
    up          => up_RegA,
    down        => down_RegA,
    datain      => alu_result,
    dataout     => regB_out
    );
    
-- FALTA inst_MuxA: Mux port map();
inst_MuxerA: Mux port map(
        datain_0 =>  "0000000000000000",            --Creo que falta señal de 0
        datain_1 =>  "0000000000000001",             --Creo que falta señal de 1
        datain_2 =>  "0000000000000000",             --Null ( No se selecciona )
        datain_3 =>  regA_out,                       --regA,
        sel => selA,                                 --selA
        dataout => muxA_out                          --muxA_out
);
-- FALTA inst_MuxB: Mux port map();
inst_MuxerB: Mux port map(
        datain_0 => "0000000000000000",              --señal de 0 pero para MuxerB
        datain_1 => regB_out,                        --RegB
        datain_2 => ram_dataout,                     --litMB (falta litMB como señal)
        datain_3 => rom_dataout_muxerB,              --rom_dataout (no se si no esta o no es señal)
        sel => selB,                                 --selB
        dataout => muxB_out                          --muxB_out
);
    
inst_ALU: ALU port map(
    a => muxA_out, 
    b => muxB_out, 
    sop => selALU,  
    c => z,
    z => c,
    n => n,
    result => alu_result
);

inst_Stauts: Status port map(
     c     => c, 
     z     => z,
     n     => n,
     clock => clock,
     out_status  => status_out
     );

--Nose valores count_in y load_pc
inst_PC: ProgramCounter port map(
    clock => clock,
    count_in => next_pc_value,
    load_pc => load_pc,
    clear => clear,
    count_out => pc_dataout
);

--nose valores load PC
inst_Control_Unit : ControlUnit Port map (

    datain => rom_dataout(19 downto 0),
    status => status_out,
    enableA => enableA,
    enableB => enableB,
    selA => selA,
    selB => selB,
    selALU => selALU,
    loadPC => load_PC,
    w => write_ram

);


end Behavioral;

