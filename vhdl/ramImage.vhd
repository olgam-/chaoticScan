library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ramImage is
generic (
	N : integer := 14  -- here 14 because 2^14 = 128 * 128
);
port
(
	clk			  : in  std_logic;
	rst			  : in  std_logic;
	data		  : in  std_logic_vector(7 downto 0);
	write_address : in  std_logic_vector(N - 1 downto 0);
	read_address  : in  std_logic_vector(N - 1 downto 0);
	we			  : in  std_logic;
	q			  : out std_logic_vector(7 downto 0)
);
end ramImage;

architecture rtl of ramImage is

type RAM is array(0 to (2 ** N - 1)) of std_logic_vector(7 downto 0);
signal ram_block : RAM;

begin

process (clk,rst)
begin
	if (rst = '1') then
		for i in 0 to (2 ** N - 1) loop
			ram_block(i) <= (others => '0');
		end loop;
	elsif rising_edge(clk) then
		if (we = '1') then
			ram_block(to_integer(unsigned(write_address))) <= data;
		end if;
		q <= ram_block(to_integer(unsigned(read_address)));
	end if;
end process;

end rtl;
