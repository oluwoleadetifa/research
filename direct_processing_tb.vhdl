library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library std;
use std.textio.ALL;

entity direct_processing_tb is
end direct_processing_tb;

architecture Behavioral of direct_processing_tb is
    constant DATA_WIDTH : integer := 32;

    component DirectProcessing
        generic (
            DATA_WIDTH : integer
        );
        port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            raw_data : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
            processed_data : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
        );
    end component;

    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '1';
    signal raw_data : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
    signal processed_data : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

    constant clk_period : time := 10 ns;

    file raw_data_file : text open read_mode is "raw_data.hex";
    file output_file : text open write_mode is "processed_data_output.txt";

    function to_stdlogicvector(hex_str : string) return STD_LOGIC_VECTOR is
        variable result : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        constant hex_chars : string := "0123456789ABCDEF";
        variable nibble : STD_LOGIC_VECTOR(3 downto 0);
    begin
        for i in 0 to hex_str'length - 1 loop
            for j in 0 to 15 loop
                if hex_str(i+1) = hex_chars(j+1) then
                    nibble := std_logic_vector(to_unsigned(j, 4));
                    result((i+1)*4 - 1 downto i*4) := nibble;
                end if;
            end loop;
        end loop;
        return result;
    end function;

    function to_hex(data : STD_LOGIC_VECTOR) return string is
        variable hex_str : string(1 to DATA_WIDTH / 4);
        variable nibble : STD_LOGIC_VECTOR(3 downto 0);
        constant hex_chars : string := "0123456789ABCDEF";
    begin
        for i in 0 to (DATA_WIDTH / 4) - 1 loop
            nibble := data((i + 1) * 4 - 1 downto i * 4);
            case nibble is
                when "0000" => hex_str(i + 1) := '0';
                when "0001" => hex_str(i + 1) := '1';
                when "0010" => hex_str(i + 1) := '2';
                when "0011" => hex_str(i + 1) := '3';
                when "0100" => hex_str(i + 1) := '4';
                when "0101" => hex_str(i + 1) := '5';
                when "0110" => hex_str(i + 1) := '6';
                when "0111" => hex_str(i + 1) := '7';
                when "1000" => hex_str(i + 1) := '8';
                when "1001" => hex_str(i + 1) := '9';
                when "1010" => hex_str(i + 1) := 'A';
                when "1011" => hex_str(i + 1) := 'B';
                when "1100" => hex_str(i + 1) := 'C';
                when "1101" => hex_str(i + 1) := 'D';
                when "1110" => hex_str(i + 1) := 'E';
                when "1111" => hex_str(i + 1) := 'F';
                when others => hex_str(i + 1) := '0';
            end case;
        end loop;
        return hex_str;
    end function;

begin
    uut: DirectProcessing
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            reset => reset,
            raw_data => raw_data,
            processed_data => processed_data
        );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    stimulus_process : process
        variable input_line : line;
        variable output_line : line;
        variable hex_string : string(1 to DATA_WIDTH / 4);
        variable raw_data_value : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        variable processed_data_str : string(1 to DATA_WIDTH / 4);
    begin
        reset <= '1';
        wait for clk_period * 2;
        reset <= '0';

        while not endfile(raw_data_file) loop
            readline(raw_data_file, input_line);
            read(input_line, hex_string);

            raw_data_value := to_stdlogicvector(hex_string);
            raw_data <= raw_data_value;

            wait for clk_period;

            processed_data_str := to_hex(processed_data);

            write(output_line, processed_data_str);
            writeline(output_file, output_line);

            report "Processed: " & processed_data_str;
        end loop;

        wait;
    end process;
end Behavioral;
