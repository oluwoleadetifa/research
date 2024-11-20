IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Testbench is
end Testbench;

architecture Behavioral of Testbench is

    -- Component Declaration for the Unit Under Test (UUT)
    component PostProcessing
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            raw_data : in STD_LOGIC_VECTOR(31 downto 0);
            processed_data : out STD_LOGIC_VECTOR(31 downto 0);
            anomaly_detected : out STD_LOGIC
        );
    end component;

    -- Signals for simulation
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '1';
    signal raw_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal processed_data : STD_LOGIC_VECTOR(31 downto 0);
    signal anomaly_detected : STD_LOGIC;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: PostProcessing
        Port map (
            clk => clk,
            reset => reset,
            raw_data => raw_data,
            processed_data => processed_data,
            anomaly_detected => anomaly_detected
        );

    -- Clock process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Reset process
    stimulus_process : process
    begin
        -- Apply reset
        reset <= '1';
        wait for clk_period * 2;
        reset <= '0';
        
        -- Apply test vectors
        raw_data <= X"00000001"; -- Example input
        wait for clk_period;
        
        raw_data <= X"00000002"; -- Another input
        wait for clk_period;

        -- Test case for anomaly detection
        raw_data <= X"FFFFFFFF"; -- Anomaly input
        wait for clk_period;

        -- Test case for reset
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait for clk_period;

        -- Further test cases can be added here

        -- Finish simulation
        wait;
    end process;

    -- Assertion process
    assertion_process : process
    begin
        wait for clk_period * 2;
        assert anomaly_detected = '0' report "Anomaly detected unexpectedly" severity error;
        wait for clk_period;
        assert anomaly_detected = '1' report "Anomaly not detected" severity error;
        wait;
    end process;

end Behavioral;