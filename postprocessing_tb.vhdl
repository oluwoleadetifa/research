library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library std;
use std.textio.ALL;

entity PostProcessing_tb is
end PostProcessing_tb;

architecture Behavioral of PostProcessing_tb is
    constant DATA_WIDTH : integer := 32;

    component PostProcessing
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

    -- Convert hex string to std_logic_vector
    function to_stdlogicvector(hex_str : string) return STD_LOGIC_VECTOR is
        variable result : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
        variable nibble : STD_LOGIC_VECTOR(3 downto 0);
        variable idx : integer;
    begin
        for i in 0 to hex_str'length - 1 loop
            case hex_str(i + 1) is
                when '0' => nibble := "0000";
                when '1' => nibble := "0001";
                when '2' => nibble := "0010";
                when '3' => nibble := "0011";
                when '4' => nibble := "0100";
                when '5' => nibble := "0101";
                when '6' => nibble := "0110";
                when '7' => nibble := "0111";
                when '8' => nibble := "1000";
                when '9' => nibble := "1001";
                when 'A' | 'a' => nibble := "1010";
                when 'B' | 'b' => nibble := "1011";
                when 'C' | 'c' => nibble := "1100";
                when 'D' | 'd' => nibble := "1101";
                when 'E' | 'e' => nibble := "1110";
                when 'F' | 'f' => nibble := "1111";
                when others => nibble := "0000";
            end case;
            idx := (hex_str'length - 1 - i) * 4;
            result(idx + 3 downto idx) := nibble;
        end loop;
        return result;
    end function;

    -- Convert std_logic_vector to hex string
    function to_hex(data : STD_LOGIC_VECTOR) return string is
        variable hex_str : string(1 to DATA_WIDTH / 4);
        variable nibble : STD_LOGIC_VECTOR(3 downto 0);
    begin
        for i in 0 to (DATA_WIDTH / 4) - 1 loop
            nibble := data((DATA_WIDTH - 1 - i * 4) downto (DATA_WIDTH - 4 - i * 4));
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
    uut: PostProcessing
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            reset => reset,
            raw_data => raw_data,
            processed_data => processed_data
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus
    stimulus_process : process
        variable line_buffer : line;
        variable hex_string : string(1 to DATA_WIDTH / 4);
        variable raw_data_value : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        variable processed_data_str : string(1 to DATA_WIDTH / 4);
    begin
        wait for clk_period;
        reset <= '1';
        wait for clk_period * 2;
        reset <= '0';

        while not endfile(raw_data_file) loop
            readline(raw_data_file, line_buffer);
            read(line_buffer, hex_string);
            raw_data_value := to_stdlogicvector(hex_string);
            raw_data <= raw_data_value;

            wait for clk_period * 2;  -- Allow processing to occur

            processed_data_str := to_hex(processed_data);
            write(line_buffer, processed_data_str);
            writeline(output_file, line_buffer);
        end loop;

        wait;
    end process;
end Behavioral;
