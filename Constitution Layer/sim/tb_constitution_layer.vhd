-- ============================================================================
-- Name: Max Maehara
-- Project: FPGA Constitution Layer
-- File: tb_constitution_layer.vhd
-- Date Started: 2026-05-10
-- Last Edited: 2026-05-10
--
-- Purpose:
-- Testbench for the immutable constitutional enforcement layer.
--
-- This testbench validates:
--   * Containment enforcement
--   * Self-destruction prevention
--   * Constitutional integrity enforcement
--   * Physical safety monitoring
--   * Structural integrity enforcement
--   * Procedural fairness enforcement
--
-- The objective is to ensure:
--   * Violations are detected
--   * Emergency halt is asserted
--   * Violation codes are preserved
--   * Halt remains latched until manual reset
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_constitution_layer is
end tb_constitution_layer;

architecture Behavioral of tb_constitution_layer is

    -- =========================================================================
    -- Clock
    -- =========================================================================

    signal clk : STD_LOGIC := '0';

    -- =========================================================================
    -- Reset
    -- =========================================================================

    signal manual_reset : STD_LOGIC := '0';

    -- =========================================================================
    -- Tier I : Physical Safety Signals
    -- =========================================================================

    signal power_sensor   : unsigned(15 downto 0) := x"0000";
    signal temp_sensor    : unsigned(15 downto 0) := x"0000";
    signal voltage_sensor : unsigned(15 downto 0) := x"0000";

    signal power_sensor_valid   : STD_LOGIC := '1';
    signal temp_sensor_valid    : STD_LOGIC := '1';
    signal voltage_sensor_valid : STD_LOGIC := '1';

    -- =========================================================================
    -- Article I : Containment Signals
    -- =========================================================================

    signal external_io_req      : STD_LOGIC := '0';
    signal network_req          : STD_LOGIC := '0';
    signal dma_external_req     : STD_LOGIC := '0';
    signal external_storage_req : STD_LOGIC := '0';
    signal self_replication_req : STD_LOGIC := '0';

    -- =========================================================================
    -- Article II : Self-Destruction Signals
    -- =========================================================================

    signal self_modify_req      : STD_LOGIC := '0';
    signal watchdog_disable_req : STD_LOGIC := '0';
    signal clock_tamper_req     : STD_LOGIC := '0';
    signal power_ctrl_write_req : STD_LOGIC := '0';
    signal audit_disable_req    : STD_LOGIC := '0';

    -- =========================================================================
    -- Article III : Constitutional Integrity Signals
    -- =========================================================================

    signal rule_modify_req        : STD_LOGIC := '0';
    signal threshold_modify_req   : STD_LOGIC := '0';
    signal enforcement_bypass_req : STD_LOGIC := '0';
    signal unsigned_bitstream_req : STD_LOGIC := '0';

    -- =========================================================================
    -- Tier II : Structural Integrity Signals
    -- =========================================================================

    signal evaluator_count    : unsigned(3 downto 0) := "0011";
    signal meta_auditor_count : unsigned(3 downto 0) := "0010";

    signal generation_timeout : STD_LOGIC := '0';
    signal agent_unresponsive : STD_LOGIC := '0';
    signal watchdog_heartbeat : STD_LOGIC := '1';

    -- =========================================================================
    -- Tier III : Procedural Fairness Signals
    -- =========================================================================

    signal evaluator_weight_violation    : STD_LOGIC := '0';
    signal evaluator_influence_violation : STD_LOGIC := '0';
    signal proxy_vote_detected           : STD_LOGIC := '0';
    signal auditor_quorum_failure        : STD_LOGIC := '0';

    -- =========================================================================
    -- Outputs
    -- =========================================================================

    signal agent_enable   : STD_LOGIC;
    signal emergency_stop : STD_LOGIC;

    signal violation_code : STD_LOGIC_VECTOR(7 downto 0);

begin

    -- =========================================================================
    -- Clock Generation
    -- =========================================================================

    clk <= not clk after 5 ns;

    -- =========================================================================
    -- Unit Under Test
    -- =========================================================================

    uut: entity work.constitution_layer
        port map (

            clk => clk,
            manual_reset => manual_reset,

            power_sensor => power_sensor,
            temp_sensor => temp_sensor,
            voltage_sensor => voltage_sensor,

            power_sensor_valid => power_sensor_valid,
            temp_sensor_valid => temp_sensor_valid,
            voltage_sensor_valid => voltage_sensor_valid,

            external_io_req => external_io_req,
            network_req => network_req,
            dma_external_req => dma_external_req,
            external_storage_req => external_storage_req,
            self_replication_req => self_replication_req,

            self_modify_req => self_modify_req,
            watchdog_disable_req => watchdog_disable_req,
            clock_tamper_req => clock_tamper_req,
            power_ctrl_write_req => power_ctrl_write_req,
            audit_disable_req => audit_disable_req,

            rule_modify_req => rule_modify_req,
            threshold_modify_req => threshold_modify_req,
            enforcement_bypass_req => enforcement_bypass_req,
            unsigned_bitstream_req => unsigned_bitstream_req,

            evaluator_count => evaluator_count,
            meta_auditor_count => meta_auditor_count,

            generation_timeout => generation_timeout,
            agent_unresponsive => agent_unresponsive,
            watchdog_heartbeat => watchdog_heartbeat,

            evaluator_weight_violation => evaluator_weight_violation,
            evaluator_influence_violation => evaluator_influence_violation,
            proxy_vote_detected => proxy_vote_detected,
            auditor_quorum_failure => auditor_quorum_failure,

            agent_enable => agent_enable,
            emergency_stop => emergency_stop,
            violation_code => violation_code
        );

    -- =========================================================================
    -- Test Process
    -- =========================================================================

    process
    begin

        -- =====================================================================
        -- NORMAL OPERATION
        -- =====================================================================

        wait for 20 ns;

        -- =====================================================================
        -- ARTICLE I : NETWORK VIOLATION
        -- =====================================================================

        network_req <= '1';

        wait for 20 ns;

        network_req <= '0';

        -- =====================================================================
        -- MANUAL RESET
        -- =====================================================================

        manual_reset <= '1';

        wait for 20 ns;

        manual_reset <= '0';

        wait for 20 ns;

        -- =====================================================================
        -- ARTICLE II : WATCHDOG DISABLE ATTEMPT
        -- =====================================================================

        watchdog_disable_req <= '1';

        wait for 20 ns;

        watchdog_disable_req <= '0';

        -- =====================================================================
        -- MANUAL RESET
        -- =====================================================================

        manual_reset <= '1';

        wait for 20 ns;

        manual_reset <= '0';

        wait for 20 ns;

        -- =====================================================================
        -- ARTICLE III : RULE MODIFICATION ATTEMPT
        -- =====================================================================

        rule_modify_req <= '1';

        wait for 20 ns;

        rule_modify_req <= '0';

        -- =====================================================================
        -- MANUAL RESET
        -- =====================================================================

        manual_reset <= '1';

        wait for 20 ns;

        manual_reset <= '0';

        wait for 20 ns;

        -- =====================================================================
        -- TIER I : OVER TEMPERATURE
        -- =====================================================================

        temp_sensor <= x"0050";

        wait for 20 ns;

        temp_sensor <= x"0000";

        -- =====================================================================
        -- MANUAL RESET
        -- =====================================================================

        manual_reset <= '1';

        wait for 20 ns;

        manual_reset <= '0';

        wait for 20 ns;

        -- =====================================================================
        -- TIER II : LOW EVALUATOR COUNT
        -- =====================================================================

        evaluator_count <= "0001";

        wait for 20 ns;

        evaluator_count <= "0011";

        -- =====================================================================
        -- MANUAL RESET
        -- =====================================================================

        manual_reset <= '1';

        wait for 20 ns;

        manual_reset <= '0';

        wait for 20 ns;

        -- =====================================================================
        -- TIER III : PROXY VOTE DETECTED
        -- =====================================================================

        proxy_vote_detected <= '1';

        wait for 20 ns;

        proxy_vote_detected <= '0';

        -- =====================================================================
        -- END SIMULATION
        -- =====================================================================

        wait;

    end process;

end Behavioral;