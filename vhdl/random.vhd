library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity random is
generic (
	N : integer := 14
);
port (
	clk 	: in std_logic;
	rst 	: in std_logic;
	randomNum : out std_logic_vector (2 ** N-1 downto 0)
);
end random;


architecture Behavioral of random is

-- signal newRandom : std_logic_vector(2 ** N-1 downto 0) := (2 ** N-1 => '1', others => '0');
signal newRandom : std_logic_vector(2 ** N-1 downto 0);
signal temp      : std_logic := '0';

begin

process(clk,rst)
begin
	if rst = '1' then
		temp <= '0';
		newRandom <= std_logic_vector(to_unsigned((2**N / 2) + 8, 2 ** N));
	elsif rising_edge(clk)  then
		temp <= newRandom(2 ** N-1) xor newRandom(2 ** N-2);
		newRandom(2 ** N-1 downto 1) <= newRandom(2 ** N-2 downto 0);
		newRandom(0) <= temp;
	end if;
end process;

randomNum <= newRandom;

end;