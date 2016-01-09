library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity chaoticFSM is
generic (
	N : integer := 14;
	NumOfMoves : integer := 6500 
);
port (
	clk          	: in  std_logic;
	rst          	: in  std_logic;
	Done          	: in  std_logic;
	mask            : in  std_logic_vector(N-1 downto 0);
	randomNum       : in  std_logic_vector(2 ** N-1 downto 0);
	outAddress   	: out integer
);
end chaoticFSM;

architecture bhv of chaoticFSM is

signal address    : integer;
signal newAddress : std_logic_vector(N-1 downto 0);
signal moves      : integer := NumOfMoves;
signal isNew      : std_logic;
signal cycle      : std_logic_vector(N-1 downto 0);

signal randomState : std_logic_vector(2 ** N-1 downto 0);
-- signal mask     : std_logic_vector(N-1 downto 0) := "00000101010101"; -- 341dec
-- signal mask        : std_logic_vector(N-1 downto 0) := "01010011011100"; -- 5340dec

type array_type1 is array (0 to NumOfMoves - 1) of integer; 
signal addressArray : array_type1; 

type statetype is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10);
signal state, nextstate : statetype;
 
begin

-- Next State Register --
process(rst,clk)
begin
	if (rst = '1') then
		state <= S0;
	elsif (rising_edge(clk)) then
		state <= nextstate;
	end if;
end process;

-- Next State Logic --
process(state,rst,clk,Done,moves,address)
begin
if rst = '1' then
	nextstate <= S0;
elsif (rising_edge(clk)) then
	case state is
		when S0 => 	if Done = '1' then
						nextstate <= S1;
					else 
						nextstate <= S0;
					end if;
		when S1 => 	if address > (2**N-1 - N/2 - 1) then
						nextstate <= S3;
					elsif address < (N/2 - 2) then
						nextstate <= S4;
					else
						nextstate <= S2;
					end if;
		when S2 => 	nextstate <= S5;
		when S3 =>  nextstate <= S5;
		when S4 =>  nextstate <= S5;
		when S5 => 	nextstate <= S6;
		when S6 =>  nextstate <= S7;
		when S7 => 	if isNew = '1'  then
						nextstate <= S8;
					else 
						nextstate <= S1;
					end if;
		when S8 =>  nextstate <= S9; 
		when S9 => 	if moves > 0  then
						nextstate <= S1;
					elsif moves = 0  then
						nextstate <= S10; 
					else 
						nextstate <= state;
					end if;
		when S10 => nextstate <= state;
	end case;
end if;
end process;

-- Output Logic --
process(rst,state)
begin
	if (rst = '1') then
		newAddress <= (others => '0');
		isNew <= '1';
		moves <= NumOfMoves;
		for i in 0 to NumOfMoves - 1 loop
	    	addressArray(i) <= 0;
		end loop;
	else
		case state is
			-- when S0 =>  if Done = '1' then 
							-- -- randomState <= randomNum;
							-- randomState <= std_logic_vector(to_unsigned((2**N / 2) + 8, 2 ** N));
						-- end if;
			when S0 =>  randomState <= randomNum;

			when S1 =>  isNew <= '1';
						-- Rule 101 -- 
						for i in 1 to 2 ** N - 2 loop
							randomState(i) <= (( randomState(i-1) and ( not randomState(i) ) and randomState(i+1)) or ((not randomState(i-1)) and (not randomState(i+1))) or (randomState(i) and (not randomState(i+1))));
						end loop;
						randomState(0) <= (( randomState(2 ** N - 1) and ( not randomState(0) ) and randomState(1)) or ((not randomState(2 ** N - 1)) and (not randomState(1))) or (randomState(0) and (not randomState(1))));
						randomState(2 ** N - 1) <= (( randomState(2 ** N - 2) and ( not randomState(2 ** N - 1) ) and randomState(0)) or ((not randomState(2 ** N - 2)) and (not randomState(0))) or (randomState(2 ** N - 1) and (not randomState(0))));
			when S2 =>  cycle <= randomState(address + N/2 downto address - (N/2 - 1));
			when S3 =>  cycle <= randomState((N/2 - 1 -((2**N-1) - address)) downto 0) & randomState((2**N-1) downto (address - (N/2 -1)));
			when S4 =>  cycle <= randomState((address + (N/2-1)) downto 0) & randomState ((2**N-1) downto ((2**N-1) - (N/2-1 - address)));
			-- randomState(16377 downto 13683) & randomState(0 downto (address + (6)));
			when S5 =>  newAddress <= mask xor cycle;
						
			when S6 =>  for i in 0 to NumOfMoves - 1 loop
							if address = addressArray(i) then
								isNew <= '0';
							end if;
						end loop;
			when S7 =>
			when S8 =>  addressArray(NumOfMoves - moves) <= address;
						outAddress <= address;
						moves <= moves - 1;
						randomState(address) <= not randomState(address);
			when S9 =>  
			when S10 => 
			when others =>
		end case;
	end if;
end process;

address <= to_integer(unsigned(newAddress));
		
end;