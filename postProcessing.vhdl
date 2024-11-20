library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PostProcessing is
    Port (
        clk              : in STD_LOGIC;
        reset            : in STD_LOGIC;
        raw_data         : in STD_LOGIC_VECTOR(31 downto 0);  -- 32-bit raw data input
        processed_data    : out STD_LOGIC_VECTOR(31 downto 0); -- 32-bit output
        anomaly_detected  : out STD_LOGIC                     -- Anomaly detection output
    );
end PostProcessing;

architecture Behavioral of PostProcessing is
    signal internal_data      : STD_LOGIC_VECTOR(31 downto 0);
    signal anomaly_detected_internal : STD_LOGIC;

    -- Constant for XOR correction (can be parameterized if needed)
    constant XOR_MASK : STD_LOGIC_VECTOR(31 downto 0) := x"AAAAAAAA";
begin
    -- Process for data correction and anomaly detection
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                internal_data <= (others => '0');
                anomaly_detected_internal <= '0';
            else
                -- Apply XOR correction to raw data
                internal_data <= raw_data xor XOR_MASK;

                -- Check for anomalies (example: if data pattern is all 1s)
                anomaly_detected_internal <= '1' when raw_data = (others => '1') else '0';
            end if;
        end if;
    end process;

    -- Output the processed data and anomaly detection signal
    processed_data <= internal_data;
    anomaly_detected <= anomaly_detected_internal;

end Behavioral;
