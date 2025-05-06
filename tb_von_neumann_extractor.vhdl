library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity Testbench is
end entity Testbench;

architecture sim of Testbench is
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal data_in   : std_logic;
    signal valid_in  : std_logic := '0';
    signal data_out  : std_logic;
    signal valid_out : std_logic;

    component VNPostProcessing
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            data_in   : in  std_logic;
            valid_in  : in  std_logic;
            data_out  : out std_logic;
            valid_out : out std_logic
        );
    end component;

    constant clk_period : time := 10 ns;

    file input_file  : text open read_mode is "raw_random.hex";
    file output_file : text open write_mode is "von_neumann.hex";

begin
    clk <= not clk after clk_period / 2;

    uut: VNPostProcessing
        port map (
            clk       => clk,
            rst       => rst,
            data_in   => data_in,
            valid_in  => valid_in,
            data_out  => data_out,
            valid_out => valid_out
        );

    process
        variable l         : line;
        variable hex_str   : string(1 to 2);
        variable byte_val  : integer;
        variable byte      : std_logic_vector(7 downto 0);
        variable bit_idx   : integer;
        variable buf_out   : std_logic_vector(7 downto 0) := (others => '0');
        variable bit_count : integer := 0;
        variable out_line  : line;
        variable c         : character;
    begin
        wait for 100 ns;
        rst <= '0';

        while not endfile(input_file) loop
            readline(input_file, l);
            for i in 1 to 2 loop
                read(l, c);
                hex_str(i) := c;
            end loop;

            -- Convert hex_str to integer value
            case hex_str(1) is
                when '0' to '9' => byte_val := character'pos(hex_str(1)) - character'pos('0');
                when 'A' to 'F' => byte_val := 10 + character'pos(hex_str(1)) - character'pos('A');
                when 'a' to 'f' => byte_val := 10 + character'pos(hex_str(1)) - character'pos('a');
                when others     => byte_val := 0;
            end case;
            byte_val := byte_val * 16;
            case hex_str(2) is
                when '0' to '9' => byte_val := byte_val + character'pos(hex_str(2)) - character'pos('0');
                when 'A' to 'F' => byte_val := byte_val + 10 + character'pos(hex_str(2)) - character'pos('A');
                when 'a' to 'f' => byte_val := byte_val + 10 + character'pos(hex_str(2)) - character'pos('a');
                when others     => byte_val := byte_val + 0;
            end case;

            byte := std_logic_vector(to_unsigned(byte_val, 8));

            for bit_idx in 7 downto 0 loop
                data_in  <= byte(bit_idx);
                valid_in <= '1';
                wait until rising_edge(clk);
                valid_in <= '0';
                wait until rising_edge(clk);

                if valid_out = '1' then
                    buf_out := buf_out(6 downto 0) & data_out;
                    bit_count := bit_count + 1;
                    if bit_count = 8 then
                        hwrite(out_line, buf_out);
                        writeline(output_file, out_line);
                        bit_count := 0;
                    end if;
                end if;
            end loop;
        end loop;

        -- Write final byte if needed
        if bit_count /= 0 then
            for i in bit_count to 7 loop
                buf_out := buf_out(6 downto 0) & '0';
            end loop;
            hwrite(out_line, buf_out);
            writeline(output_file, out_line);
        end if;

        wait;
    end process;
end architecture sim;
