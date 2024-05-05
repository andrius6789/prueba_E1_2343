library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Basys3 is
    Port (
        sw          : in   std_logic_vector (15 downto 0); -- No Tocar - Se�ales de entrada de los interruptores -- Arriba   = '1'   -- Los 16 swiches.
        btn         : in   std_logic_vector (4 downto 0);  -- No Tocar - Se�ales de entrada de los botones       -- Apretado = '1'   -- 0 central, 1 arriba, 2 izquierda, 3 derecha y 4 abajo.
        led         : out  std_logic_vector (15 downto 0); -- No Tocar - Se�ales de salida  a  los leds          -- Prendido = '1'   -- Los 16 leds.
        clk         : in   std_logic;                      -- No Tocar - Se�al de entrada del clock              -- 100Mhz.
        seg         : out  std_logic_vector (7 downto 0);  -- No Tocar - Salida de las se�ales de segmentos.
        an          : out  std_logic_vector (3 downto 0);  -- No Tocar - Salida del selector de diplay.
        tx          : out  std_logic;                      -- No Tocar - Se�al de salida para UART Tx.
        rx          : in   std_logic                       -- No Tocar - Se�al de entrada para UART Rx.
          );
end Basys3;

architecture Behavioral of Basys3 is

-- Inicio de la declaraci�n de los componentes.

component Clock_Divider -- No Tocar
    Port (
        clk         : in    std_logic;
        speed       : in    std_logic_vector (1 downto 0);
        clock       : out   std_logic
          );
    end component;
    
component Display_Controller -- No Tocar
    Port (  
        dis_a       : in    std_logic_vector (3 downto 0);
        dis_b       : in    std_logic_vector (3 downto 0);
        dis_c       : in    std_logic_vector (3 downto 0);
        dis_d       : in    std_logic_vector (3 downto 0);
        clk         : in    std_logic;
        seg         : out   std_logic_vector (7 downto 0);
        an          : out   std_logic_vector (3 downto 0)
          );
    end component;
    
component Debouncer -- No Tocar
    Port (
        clk         : in    std_logic;
        signal_in      : in    std_logic;
        signal_out     : out   std_logic
          );
    end component;
            

component ROM -- No Tocar
    Port (
        clk         : in    std_logic;
        write       : in    std_logic;
        disable     : in    std_logic;
        address     : in    std_logic_vector (11 downto 0);
        dataout     : out   std_logic_vector (35 downto 0);
        datain      : in    std_logic_vector(35 downto 0)
          );
    end component;

component RAM -- No Tocar
    Port (  
        clock       : in    std_logic;
        write       : in    std_logic;
        address     : in    std_logic_vector (11 downto 0);
        datain      : in    std_logic_vector (15 downto 0);
        dataout     : out   std_logic_vector (15 downto 0)
          );
    end component;
    
component Programmer -- No Tocar
    Port (
        rx          : in    std_logic;
        tx          : out   std_logic;
        clk         : in    std_logic;
        clock       : in    std_logic;
        bussy       : out   std_logic;
        ready       : out   std_logic;
        address     : out   std_logic_vector(11 downto 0);
        dataout     : out   std_logic_vector(35 downto 0)
        );
    end component;
    
component CPU is
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
    end component;

component Mux is
    Port (
        datain_0 : in STD_LOGIC_VECTOR(15 downto 0); 
        datain_1 : in STD_LOGIC_VECTOR(15 downto 0);
        datain_2 : in STD_LOGIC_VECTOR(15 downto 0);
        datain_3 : in STD_LOGIC_VECTOR(15 downto 0);
        sel : in STD_LOGIC_VECTOR(15 downto 0);
        dataout : out STD_LOGIC_VECTOR(15 downto 0));
    end component;

component Reg is
    Port ( 
        clock    : in  std_logic;                        -- Se�al del clock (reducido).
        clear    : in  std_logic;                        -- Se�al de reset.
        load     : in  std_logic;                        -- Se�al de carga.
        up       : in  std_logic;                        -- Se�al de subida.
        down     : in  std_logic;                        -- Se�al de bajada.
        datain   : in  std_logic_vector (15 downto 0);   -- Se�ales de entrada de datos.
        dataout  : out std_logic_vector (15 downto 0));  -- Se�ales de salida de datos.
    end component;
    
-- Fin de la declaraci�n de los componentes.

-- Inicio de la declaraci�n de se�ales.

signal clock            : std_logic;                     -- Se�al del clock reducido.
            
signal dis_a            : std_logic_vector(3 downto 0);  -- Se�ales de salida al display A.    
signal dis_b            : std_logic_vector(3 downto 0);  -- Se�ales de salida al display B.     
signal dis_c            : std_logic_vector(3 downto 0);  -- Se�ales de salida al display C.    
signal dis_d            : std_logic_vector(3 downto 0);  -- Se�ales de salida al display D.

signal dis              : std_logic_vector(15 downto 0); -- Se�ales de salida totalidad de los displays.

signal d_btn            : std_logic_vector(4 downto 0);  -- Se�ales de botones con anti-rebote.

signal write_rom        : std_logic;                     -- Se�al de escritura de la ROM.
signal pro_address      : std_logic_vector(11 downto 0); -- Se�ales del direccionamiento de programaci�n de la ROM.
signal rom_datain       : std_logic_vector(35 downto 0); -- Se�ales de la palabra a programar en la ROM.

signal clear            : std_logic;                     -- Se�al de limpieza de registros durante la programaci�n.

signal cpu_rom_address  : std_logic_vector(11 downto 0); -- Se�ales del direccionamiento de lectura de la ROM.
signal rom_address      : std_logic_vector(11 downto 0); -- Se�ales del direccionamiento de la ROM.
signal rom_dataout      : std_logic_vector(35 downto 0); -- Se�ales de la palabra de salida de la ROM.

signal write_ram        : std_logic;                     -- Se�al de escritura de la RAM.
signal ram_address      : std_logic_vector(11 downto 0); -- Se�ales del direccionamiento de la RAM.
signal ram_datain       : std_logic_vector(15 downto 0); -- Se�ales de la palabra de entrada de la RAM.
signal ram_dataout      : std_logic_vector(15 downto 0); -- Se�ales de la palabra de salida de la RAM.

-- Fin de la declaraci�n de los se�ales.

begin

dis_a  <= dis(15 downto 12);
dis_b  <= dis(11 downto 8);
dis_c  <= dis(7 downto 4);
dis_d  <= dis(3 downto 0);
                    
-- Muxer del address de la ROM.          
with clear select
    rom_address <= cpu_rom_address when '0',
                   pro_address when '1';
                   
-- Inicio de declaraci�n de instancias.

-- Instancia de la CPU.        
inst_CPU: CPU port map(
    clock       => clock,
    clear       => clear,
    ram_address => ram_address,
    ram_datain  => ram_datain,
    ram_dataout => ram_dataout,
    ram_write   => write_ram,
    rom_address => cpu_rom_address,
    rom_dataout => rom_dataout,
    dis         => dis
    );

-- Instancia de la memoria RAM.
inst_ROM: ROM port map(
    clk         => clk,
    disable     => clear,
    write       => write_rom,
    address     => rom_address,
    dataout     => rom_dataout,
    datain      => rom_datain
    );

-- Instancia de la memoria ROM.
inst_RAM: RAM port map(
    clock       => clock,
    write       => write_ram,
    address     => ram_address,
    datain      => ram_datain,
    dataout     => ram_dataout
    );
    
 -- Intancia del divisor de la se�al del clock.
inst_Clock_Divider: Clock_Divider port map(
    speed       => "11",                    -- Selector de velocidad: "00" full, "01" fast, "10" normal y "11" slow. 
    clk         => clk,                     -- No Tocar - Entrada de la se�al del clock completo (100Mhz).
    clock       => clock                    -- No Tocar - Salida de la se�al del clock reducido: 25Mhz, 8hz, 2hz y 0.5hz.
    );
    
 -- No Tocar - Intancia del controlador de los displays de 8 segmentos.    
inst_Display_Controller: Display_Controller port map(
    dis_a       => dis_a,                   -- No Tocar - Entrada de se�ales para el display A.
    dis_b       => dis_b,                   -- No Tocar - Entrada de se�ales para el display B.
    dis_c       => dis_c,                   -- No Tocar - Entrada de se�ales para el display C.
    dis_d       => dis_d,                   -- No Tocar - Entrada de se�ales para el display D.
    clk         => clk,                     -- No Tocar - Entrada del clock completo (100Mhz).
    seg         => seg,                     -- No Tocar - Salida de las se�ales de segmentos.
    an          => an                       -- No Tocar - Salida del selector de diplay.
	);
    
-- No Tocar - Intancias de los Debouncers.    
inst_Debouncer0: Debouncer port map( clk => clk, signal_in => btn(0), signal_out => d_btn(0) );
inst_Debouncer1: Debouncer port map( clk => clk, signal_in => btn(1), signal_out => d_btn(1) );
inst_Debouncer2: Debouncer port map( clk => clk, signal_in => btn(2), signal_out => d_btn(2) );
inst_Debouncer3: Debouncer port map( clk => clk, signal_in => btn(3), signal_out => d_btn(3) );
inst_Debouncer4: Debouncer port map( clk => clk, signal_in => btn(4), signal_out => d_btn(4) );

-- No Tocar - Intancia del ROM Programmer.           
inst_Programmer: Programmer port map(
    rx          => rx,                      -- No Tocar - Salida de la se�al de transmici�n.
    tx          => tx,                      -- No Tocar - Entrada de la se�al de recepci�n.
    clk         => clk,                     -- No Tocar - Entrada del clock completo (100Mhz).
    clock       => clock,                   -- No Tocar - Entrada del clock reducido.
    bussy       => clear,                   -- No Tocar - Salida de la se�al de programaci�n.
    ready       => write_rom,               -- No Tocar - Salida de la se�al de escritura de la ROM.
    address     => pro_address(11 downto 0),-- No Tocar - Salida de se�ales del address de la ROM.
    dataout     => rom_datain               -- No Tocar - Salida de se�ales palabra de entrada de la ROM.
        );


        
-- Fin de declaraci�n de instancias.

-- Fin de declaraci�n de comportamientos.
  
end Behavioral;