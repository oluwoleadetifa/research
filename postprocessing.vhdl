library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PostProcessing is
   generic (
       DATA_WIDTH : integer := 32  -- Parameterized data width
   );
   port (
       clk : in STD_LOGIC;
       reset : in STD_LOGIC;
       raw_data : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);  -- Raw data input
       processed_data : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)  -- Processed data output
   );
end PostProcessing;

architecture Behavioral of PostProcessing is
   signal internal_data : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
   signal anomaly_detected : STD_LOGIC := '0';
   signal von_neumann_temp : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- Temporary signal for corrected data
   signal corrected_index : integer range 0 to DATA_WIDTH/2 := 0;

   -- Constant for XOR correction
   constant XOR_MASK : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '1');
   constant ANOMALY_1 : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '1');  -- 0xFFFFFFFF
   constant ANOMALY_2 : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');  -- 0x00000000
begin
   -- XOR Corrector logic
   process(clk)
   begin
       if rising_edge(clk) then
           if reset = '1' then
               internal_data <= (others => '0');
               anomaly_detected <= '0';
           else
               -- XOR Corrector (you can replace this with your own method if necessary)
               internal_data <= raw_data xor XOR_MASK;

               -- Anomaly detection (detecting 0xFFFFFFFF or 0x00000000)
               anomaly_detected <= '0';  -- Assume no anomaly
               if raw_data = ANOMALY_1 or raw_data = ANOMALY_2 then
                   anomaly_detected <= '1';  -- Flag as anomaly
               end if;
           end if;
       end if;
   end process;

   -- Von Neumann Corrector logic
   process(clk)
   variable temp_corrected_index : integer range 0 to DATA_WIDTH/2 := 0;
   begin
       if rising_edge(clk) then
           if reset = '1' then
               von_neumann_temp <= (others => '0');
               temp_corrected_index := 0;
               corrected_index <= 0;
           else
               temp_corrected_index := 0;
               von_neumann_temp <= (others => '0');
               
               -- Ensure safe iteration based on DATA_WIDTH
               for i in 0 to (DATA_WIDTH/2 - 1) loop
                   if 2*i+1 < DATA_WIDTH then  -- Ensure index safety
                       -- Check if the two bits are different
                       if raw_data(2*i) /= raw_data(2*i+1) then
                           -- If they are different, store the value in the temporary corrected data
                           if temp_corrected_index < DATA_WIDTH/2 then
                               von_neumann_temp(temp_corrected_index) <= raw_data(2*i);
                               temp_corrected_index := temp_corrected_index + 1;
                           else
                               exit;  -- Prevent overflow
                           end if;
                       end if;
                   end if;
               end loop;

               corrected_index <= temp_corrected_index;
           end if;
       end if;
   end process;

   -- Final processed data selection
   process(clk)
   begin
       if rising_edge(clk) then
           if anomaly_detected = '1' then
               -- Replace anomaly with a new valid value or use Von Neumann correction
               processed_data <= von_neumann_temp;  -- Replace with corrected data
           else
               processed_data <= raw_data;  -- Output the valid raw data
           end if;
       end if;
   end process;

end Behavioral;
