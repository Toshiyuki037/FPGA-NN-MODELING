library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_constitution_layer is
end tb_constitution_layer;

architecture Behavioral of tb_constitution_layer is

    ---------------------------------------------------------------------------
    -- INPUT SIGNALS
    ---------------------------------------------------------------------------

    signal nn_output : signed(15 downto 0);

    signal overflow : std_logic;
    signal illegal_state : std_logic;

    signal internet_access_request : std_logic;
    signal external_scope_request : std_logic;

    signal authorized_execution : std_logic;

    ---------------------------------------------------------------------------
    -- OUTPUT SIGNALS
    ---------------------------------------------------------------------------

    signal approved_output : signed(15 downto 0);

    signal output_valid : std_logic;
    signal safe_mode : std_logic;

    signal violation_code : unsigned(7 downto 0);

begin

    ---------------------------------------------------------------------------
    -- UNIT UNDER TEST
    ---------------------------------------------------------------------------

    uut: entity work.constitution_layer
        port map (

            nn_output => nn_output,

            overflow => overflow,
            illegal_state => illegal_state,

            internet_access_request => internet_access_request,
            external_scope_request => external_scope_request,

            authorized_execution => authorized_execution,

            approved_output => approved_output,

            output_valid => output_valid,
            safe_mode => safe_mode,

            violation_code => violation_code
        );

    ---------------------------------------------------------------------------
    -- TEST PROCESS
    ---------------------------------------------------------------------------

    process
    begin

        -----------------------------------------------------------------------
        -- VALID EXECUTION
        -----------------------------------------------------------------------

        nn_output <= to_signed(100, 16);

        overflow <= '0';
        illegal_state <= '0';

        internet_access_request <= '0';
        external_scope_request <= '0';

        authorized_execution <= '1';

        wait for 10 ns;

        -----------------------------------------------------------------------
        -- INTERNET ACCESS VIOLATION
        -----------------------------------------------------------------------

        internet_access_request <= '1';

        wait for 10 ns;

        internet_access_request <= '0';

        -----------------------------------------------------------------------
        -- EXTERNAL SCOPE VIOLATION
        -----------------------------------------------------------------------

        external_scope_request <= '1';

        wait for 10 ns;

        external_scope_request <= '0';

        -----------------------------------------------------------------------
        -- UNAUTHORIZED EXECUTION
        -----------------------------------------------------------------------

        authorized_execution <= '0';

        wait for 10 ns;

        authorized_execution <= '1';

        -----------------------------------------------------------------------
        -- OVERFLOW
        -----------------------------------------------------------------------

        overflow <= '1';

        wait for 10 ns;

        overflow <= '0';

        -----------------------------------------------------------------------
        -- ILLEGAL STATE
        -----------------------------------------------------------------------

        illegal_state <= '1';

        wait for 10 ns;

        illegal_state <= '0';

        -----------------------------------------------------------------------
        -- OUTPUT TOO LARGE
        -----------------------------------------------------------------------

        nn_output <= to_signed(2000, 16);

        wait for 10 ns;

        -----------------------------------------------------------------------
        -- OUTPUT TOO SMALL
        -----------------------------------------------------------------------

        nn_output <= to_signed(-2000, 16);

        wait for 10 ns;

        wait;

    end process;

end Behavioral;