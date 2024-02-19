

library IEEE;
use IEEE.std_logic_1164.all;

entity Transmitter is
	generic (
    	g_CLKS_PER_BIT : integer := 115     -- Needs to be set correctly
    );
	 port(
		 clk : in STD_LOGIC;
		 byte_I : in STD_LOGIC_vector(7 downto 0);	-- byte to be transmited
		 start_I : in STD_LOGIC	;  --uart enable	 
		 done_O : out STD_LOGIC;  -- return 1 when UART is no transmiting
		 serial_O : out STD_LOGIC --efective output
	     );
end Transmitter;

--}} End of automatically maintained section

architecture Transmitter of Transmitter is
  type Transmitter_States is (IDLE_STATE, START_BIT_STATE,BIT_TRANSMITTER_STATE,STOP_BIT_STATE,CLEAN_UP_STATE);
  signal curent_state :Transmitter_States:= IDLE_STATE;		 
  
  signal clk_count : integer range 0 to g_CLKS_PER_BIT-1 := 0; -- used to divider clock
  signal clk_9600 : std_logic:= '0'; -- second clock
  signal bit_index : integer range 0 to 7 := 0;  -- index of bit that must be transmited 
  signal data : std_logic_vector(7 downto 0 ); --save the value of byte_I 
begin
	done_O <= '1' when curent_state = IDLE_STATE else	
		'0';	 
		
	-- Clock Divider
	process(clk,curent_state)
	begin
		if(rising_edge(clk)) then
			if(curent_state = IDLE_STATE) then 
				clk_count <= 0;
				clk_9600 <='0';
			else
				if(clk_count < (g_CLKS_PER_BIT -1)) then 
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
					serial_O <= '1';
					bit_index <= 0;
					if(start_i = '1')then 
						curent_state <= START_BIT_STATE;
						data <= byte_I;
					else
						curent_state <= IDLE_STATE;	   
					end if;
				when START_BIT_STATE =>
					serial_O <= '0';
					bit_index <= 0;
					if(clk_9600 = '1') then
						curent_state <=  BIT_TRANSMITTER_STATE;
					else 
						curent_state <= START_BIT_STATE;
					end if;	  
					
				when BIT_TRANSMITTER_STATE =>  
					serial_O <= data(bit_index);
					if(clk_9600 = '1') then	
						if(bit_index < 7) then
							bit_index <= bit_index + 1;
							curent_state <= BIT_TRANSMITTER_STATE;
						else 
							curent_state <= STOP_BIT_STATE;
						end if;
					else 
						curent_state <= BIT_TRANSMITTER_STATE;
					end if;
				when STOP_BIT_STATE => 
					bit_index <= 0;
					serial_O <= '1';
					if(clk_9600 = '1') then
						curent_state <=  IDLE_STATE;
					else 
						curent_state <= STOP_BIT_STATE;
					end if;
				when others =>
				curent_state <= IDLE_STATE;
			end case;
		end if;
	end process;

	 -- enter your statements here --

end Transmitter;
