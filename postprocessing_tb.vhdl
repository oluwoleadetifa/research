library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;

library std;
use std.textio.all;

entity PostProcessing_tb is
end PostProcessing_tb;

architecture Behavioral of PostProcessing_tb is
   -- Component Declaration
   component PostProcessing
       Port (
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           raw_data : in STD_LOGIC_VECTOR(31 downto 0);
           processed_data : out STD_LOGIC_VECTOR(31 downto 0)
       );
   end component;

   -- Signals for simulation
   signal clk : STD_LOGIC := '0';
   signal reset : STD_LOGIC := '1';
   signal raw_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
   signal processed_data : STD_LOGIC_VECTOR(31 downto 0);

   -- Clock generation
   constant clk_period : time := 10 ns;

   -- File handling
   file raw_data_file : text open read_mode is "raw_data.hex";
   file output_file : text open write_mode is "processed_data_output.txt";

begin
   -- Instantiate the Unit Under Test (UUT)
   uut: PostProcessing
       Port map (
           clk => clk,
           reset => reset,
           raw_data => raw_data,
           processed_data => processed_data
       );

   -- Clock process
   clk_process : process
   begin
       clk <= '0';
       wait for clk_period / 2;
       clk <= '1';
       wait for clk_period / 2;
   end process;

   -- Stimulus process
   stimulus_process : process
       variable line_buffer : line;
       variable raw_data_value : std_logic_vector(31 downto 0);
       variable hex_string : string(1 to 8); -- Adjust for 32-bit hexadecimal
   begin
       -- Initialize
       wait for 20 ns;
       reset <= '0';

       -- Debug: Print simulation start
       write(line_buffer, string'("Simulation started."));
       writeline(output_file, line_buffer); -- Write to output file

       -- Read data from the file and process
       while not endfile(raw_data_file) loop
           readline(raw_data_file, line_buffer);
           hread(line_buffer, raw_data_value); -- Read a hex value
           raw_data <= raw_data_value;


           wait for clk_period; -- Wait for a clock cycle to simulate input

           -- Convert processed_data to hexadecimal string
           hex_string := to_hstring(processed_data);

           -- Write processed_data to output file in hexadecimal format
           write(line_buffer, string'(hex_string & ", "));
           writeline(output_file, line_buffer); -- Write to output file
       end loop;

       -- Debug: Print simulation end
       write(output_file, string'("Simulation completed."));
       writeline(output_file, line_buffer); -- Write to output file

       wait; -- End simulation
   end process;
end Behavioral;
