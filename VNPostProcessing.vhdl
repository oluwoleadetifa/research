library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VNPostProcessing is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        data_in  : in  std_logic;
        valid_in : in  std_logic;
        data_out : out std_logic;
        valid_out: out std_logic
    );
end entity;

architecture Behavioral of VNPostProcessing is
    signal bit_buf  : std_logic_vector(1 downto 0) := (others => '0');
    signal buf_valid: boolean := false;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                bit_buf   <= (others => '0');
                valid_out <= '0';
                buf_valid <= false;
            elsif valid_in = '1' then
                if not buf_valid then
                    bit_buf(1) <= data_in;
                    buf_valid  <= true;
                    valid_out  <= '0';
                else
                    bit_buf(0) <= data_in;
                    buf_valid  <= false;

                    if bit_buf(1) /= data_in then
                        data_out  <= bit_buf(1);
                        valid_out <= '1';
                    else
                        valid_out <= '0';
                    end if;
                end if;
            else
                valid_out <= '0';
            end if;
        end if;
    end process;
end architecture;
