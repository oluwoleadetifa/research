-- direct_processing.vhdl

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DirectProcessing is
    generic (
        DATA_WIDTH : integer := 32
    );
    port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        raw_data : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        processed_data : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
    );
end DirectProcessing;

architecture Behavioral of DirectProcessing is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                processed_data <= (others => '0');
            else
                -- Direct passthrough, no post-processing
                processed_data <= raw_data;
            end if;
        end if;
    end process;
end Behavioral;
