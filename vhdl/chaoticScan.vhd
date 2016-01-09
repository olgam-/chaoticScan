library ieee;
library std;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity chaoticScan is
generic (
	N : integer := 14;
	NumOfMoves : integer := 6500
);
port (
	clk    	: in  std_logic;
	rst    	: in  std_logic
);
end chaoticScan;

-----------------------------------------------------------

architecture bhv of chaoticScan is

component random is
generic (
	N : integer := 14
);
port (
		clk 	: in std_logic;
		rst 	: in std_logic;
		randomNum : out std_logic_vector (2 ** N-1 downto 0)
);
end component;

component ramImage is
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
end component;

component chaoticFSM is
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
end component;


signal write_address   : std_logic_vector(N - 1 downto 0);
signal read_address    : std_logic_vector(N - 1 downto 0);
signal data		       : std_logic_vector(7 downto 0);
signal we              : std_logic := '0';
signal q               : std_logic_vector(7 downto 0); -- 255 gray

signal randomNum      : std_logic_vector(2 ** N-1 downto 0) := (others => '0');
-- signal mask           : std_logic_vector(N-1 downto 0) := "00000101010101"; -- 341dec
signal mask           : std_logic_vector(N-1 downto 0) := "01010011011100"; -- 5340dec

signal readDone       : std_logic;

signal endoffile      : bit := '0';
signal dataread       : integer;
signal datatosave     : integer;
signal linenumber     : integer := 1; 

signal totalRows      : integer;
signal totalColumns   : integer;
signal countRead      : std_logic_vector(2 downto 0);
signal countWrite     : std_logic_vector(2 downto 0);
signal countAddress   : std_logic_vector(N - 1 downto 0);

signal newAddress     : integer;
signal writtenAddress : integer;

-----------------------------------------------------------

begin

RAM : ramImage generic map (N  => 14) port map (clk, rst, data, write_address, read_address , we, q);
randomFill : random generic map (N  => 14) port map (clk, rst, randomNum);
FSM : chaoticFSM generic map (N  => 14, NumOfMoves => 6500) port map(clk, rst, readDone, mask, randomNum, newAddress);

--read process
reading : process (rst, clk)
    file      infile    : text is in  "C:\Users\Olga\Desktop\chaoticScan\files\puppy128.txt"; 
    variable  inline    : line;
    variable  cell      : integer;
begin
	if rst = '1' then
		endoffile <= '0';
		dataread <= 0;
		we <= '0';
		readDone <= '0';
		countRead <= (others => '0');
		countAddress <= (others => '0');
	elsif rising_edge(clk) then
		if (not endfile(infile)) then 
			readline(infile, inline); 
			read(inline, cell);
			if countRead = 0 then
				totalRows <= cell;
				countRead <= countRead + 1;
			elsif countRead = 1 then
				totalColumns <= cell;
				we <= '1';
				countRead <= countRead + 1;
			else
				dataread <= cell;
				write_address <= countAddress;
				data <= std_logic_vector(to_unsigned(cell,8));
				countAddress <= countAddress + 1;
			end if;
		else
			endoffile <= '1';
			we <= '0';
			readDone <= '1';
		end if;
	end if;
end process reading;
-- run 6554131ps
-- run 2000000ps

-----------------------------------------------------------

read_address <= std_logic_vector(to_unsigned(newAddress,N));
datatosave <= to_integer(unsigned(q));

--write process
writing : process(rst,clk)
    file     outfile  : text is out "C:\Users\Olga\Desktop\chaoticScan\matlab\puppy128chaotic.txt"; 
    variable outline  : line; 
begin
	if rst = '1' then
		countWrite <= (others => '0');
		writtenAddress <= 0;
	elsif rising_edge(clk) then
		if readDone = '1' then 
			if countWrite = 0 then
				write(outline, totalRows);
				writeline(outfile, outline);
				countWrite <= countWrite + 1;
			elsif countWrite = 1 then
				write(outline, totalColumns);
				writeline(outfile, outline);
				countWrite <= countWrite + 1;
			else
				if (newAddress /= writtenAddress) and (newAddress >= 0) then
					write(outline, writtenAddress + 1); -- Array(0) anti gia writtenAd isws new Ad
					write(outline, ' ');
					write(outline, datatosave);
					writeline(outfile, outline);
					writtenAddress <= newAddress;
				else
					null;
				end if;
			end if;
		end if;
	end if;
end process writing;

end bhv;