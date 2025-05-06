library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PostProcessing is
   generic (
       DATA_WIDTH : integer := 32
   );
   port (
       clk : in STD_LOGIC;
       reset : in STD_LOGIC;
       raw_data : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
       processed_data : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
   );
end PostProcessing;

architecture Behavioral of PostProcessing is
   signal von_neumann_result : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
   signal anomaly_detected   : STD_LOGIC := '0';

   constant ANOMALY_1 : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '1');
   constant ANOMALY_2 : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');

begin
   process(clk)
      variable temp_result   : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
      variable write_index   : integer range 0 to DATA_WIDTH-1 := 0;
   begin
      if rising_edge(clk) then
         if reset = '1' then
            von_neumann_result <= (others => '0');
            anomaly_detected   <= '0';
         else
            -- Reset variables
            temp_result := (others => '0');
            write_index := 0;

            -- Check for anomalies
            if raw_data = ANOMALY_1 or raw_data = ANOMALY_2 then
               anomaly_detected <= '1';
            else
               anomaly_detected <= '0';

               -- Von Neumann Extractor
               for i in 0 to (DATA_WIDTH / 2 - 1) loop
                  if raw_data(2 * i) /= raw_data(2 * i + 1) then
                     if write_index < DATA_WIDTH then
                        temp_result(write_index) := raw_data(2 * i);
                        write_index := write_index + 1;
                     end if;
                  end if;
               end loop;
            end if;

            -- Assign extracted bits to output
            von_neumann_result <= temp_result;
         end if;
      end if;
   end process;

   -- Output selection
   process(clk)
   begin
      if rising_edge(clk) then
         if anomaly_detected = '1' then
            processed_data <= von_neumann_result;
         else
            processed_data <= raw_data;
         end if;
      end if;
   end process;
end Behavioral;
