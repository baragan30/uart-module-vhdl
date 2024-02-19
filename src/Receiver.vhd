
library IEEE;
use IEEE.std_logic_1164.all;

entity Receiver is
	generic (
    	g_CLKS_PER_BIT : integer := 115     -- Needs to be set correctly
    );
	 port(
		 clk : in STD_LOGIC;
	 	 serial_I : in STD_LOGIC;
		 done_O : out STD_LOGIC;
		 byte_O : out STD_LOGIC_VECTOR(7 downto 0)
	     );
end Receiver;

--}} End of automatically maintained section

architecture Receiver of Receiver is  
  type Transmitter_States is (IDLE_STATE, START_BIT_STATE,BIT_TRANSMITTER_STATE,STOP_BIT_STATE,CLEAN_UP_STATE);
  signal curent_state :Transmitter_States:= IDLE_STATE;		 
  
  signal clk_count : integer range 0 to g_CLKS_PER_BIT-1 := 0; -- used to divider clock
  signal clk_9600 : std_logic:= '0'; -- second clock
  signal bit_index : integer range 0 to 7 := 0;  -- index of bit that must be transmited 
  signal byte : std_logic_vector(7 downto 0 ); --save the value of byte_I 
  
  signal data_aux : std_logic;
  signal data :std_logic; 
  
  begin
	
  -- Purpose: Double-register the incoming data.
  -- This allows it to be used in the UART RX Clock Domain.
  -- (It removes problems caused by metastabiliy) 
    process (clk,serial_I)
	begin
		data_aux <= serial_I;
		data <= data_aux;
	end process;  
	
	-- Clock Divider
	process(clk,curent_state)
	begin
		if(rising_edge(clk)) then
			if(curent_state = IDLE_STATE) then 
				clk_count <= 0;
				clk_9600 <='0';
			else
				if( (curent_state = START_BIT_STATE) and (clk_count = g_CLKS_PER_BIT / 2) )then 
					clk_count <= 0;
					clk_9600 <='1';	
				elsif(clk_count < (g_CLKS_PER_BIT -1)) then 
					clk_count <= clk_count + 1;
					clk_9600 <='0';
				else
					clk_count <= 0;
					clk_9600 <='1';
				end if;
			end if;
		end if;	
	end process; 
	
	--main process
	process(clk,clk_count)
	begin 
		--default
		if(rising_edge(clk)) then 
			case curent_state is 
				when IDLE_STATE => 
					bit_index <= 0;	
					done_O <= '0';
					if(data = '0')then 
						curent_state <= START_BIT_STATE;
					else
						curent_state <= IDLE_STATE;	   
					end if;
					
				when START_BIT_STATE =>
					done_O <= '0';
					bit_index <= 0;
					if(data = '1')then
						curent_state <= IDLE_STATE;
					elsif(clk_9600 = '1') then
						curent_state <=  BIT_TRANSMITTER_STATE;
					else 
						curent_state <= START_BIT_STATE;
					end if;	  
				when BIT_TRANSMITTER_STATE =>  	-- aici am ramas
					byte(bit_index) <= data;
					curent_state <= BIT_TRANSMITTER_STATE;
					if(clk_9600 = '1') then	
						if(bit_index < 7) then
							bit_index <= bit_index + 1;
							curent_state <= BIT_TRANSMITTER_STATE;
						else 
							bit_index <= 0;
							curent_state <= STOP_BIT_STATE;
						end if;
					else 
						curent_state <= BIT_TRANSMITTER_STATE;
					end if;
					
				when STOP_BIT_STATE => 
					bit_index <= 0;
					, <= STOP_BIT_STATE;	
					if(clk_9600 = '1') then	
						curent_state <= IDLE_STATE;
						if(data = '1' )then 
							done_O <= '1';
							byte_O <= byte;
						else
							done_O <= '0';
						end if;
						
						
					end if;
				when others =>
					curent_state <= IDLE_STATE;
			end case;
		end if;
	end process;
	
	
	 -- enter your statements here --

end Receiver;
