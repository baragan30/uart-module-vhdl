library IEEE;
use IEEE.std_logic_1164.all;

entity UART is
	 port(
	 clk : in STD_LOGIC; 
	 done_O : out STD_LOGIC;
 	serial_O : out STD_LOGIC
	 );
end UART;

--}} End of automatically maintained section

architecture UART of UART is 
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

begin
	G1: Transmitter generic map (4)
			port map (clk,"10010110",'1',done_O,serial_O);
	 

end UART;
