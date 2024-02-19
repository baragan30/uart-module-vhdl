 library IEEE;
use IEEE.std_logic_1164.all;   
use	ieee.std_logic_unsigned.all; 


entity UART_TESTER is
	port(
	 clk : in STD_LOGIC; 
	 data_transmited : inout STD_LOGIC_vector(7 downto 0);
	 done_transmitter: inout std_logic;
	 done_Receiver : inout std_logic;
 	 data_receiver : inout STD_LOGIC_vector(7 downto 0)
	     );
end UART_TESTER;

--}} End of automatically maintained section

architecture UART_TESTER of UART_TESTER is
component Transmitter is
	generic (
    	g_CLKS_PER_BIT : integer := 115     -- Needs to be set correctly
    );
	 port(
		 clk : in STD_LOGIC;
		 byte_I : in STD_LOGIC_vector(7 downto 0);
		 start_I : in STD_LOGIC	;	 
		 done_O : out STD_LOGIC;
		 serial_O : out STD_LOGIC
	     );
end component; 

component Receiver is
	generic (
    	g_CLKS_PER_BIT : integer := 115     -- Needs to be set correctly
    );
	 port(
		 clk : in STD_LOGIC;
	 	 serial_I : in STD_LOGIC;
		 done_O : out STD_LOGIC;
		 byte_O : out STD_LOGIC_VECTOR(7 downto 0)
	     );
end component;	  
signal index : integer range 0 to 100;
type regArray  is array (0 to 31) of std_logic_vector(7 downto 0);
signal data : regArray :=(
	"10101010",
	"10101011",
	"10101100",
	"10101101",
	others=> "00000000" );
signal serial :std_logic;
begin
	process(clk,done_transmitter)
	begin 
		if(rising_edge(clk)) then
			if(done_transmitter = '1') then
				if(index < 4)then
					index <= index + 1;
				else 
					index <= 0;
				end if;
			end if;
		end if;
	end process;
	data_transmited <= data(index);

		G1: Transmitter generic map (4)
		port map (clk,data_transmited,'1',done_transmitter,serial); 
		G2: Receiver generic map (4)
			port map (clk,serial,done_Receiver,data_receiver);

end UART_TESTER;
