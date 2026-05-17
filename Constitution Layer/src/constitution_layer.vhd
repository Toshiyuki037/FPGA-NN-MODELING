-- ============================================================================
-- Name: Max Maehara
-- Project: FPGA Constitution Layer
-- File: constitution_layer.vhd
-- Date Started: 2026-05-10
-- Last Edited: 2026-05-10
--
-- Purpose:
-- This module acts as a fixed constitutional enforcement layer for future
-- FPGA neural-network systems.
--
-- The purpose of this layer is to enforce immutable hardware rules before
-- outputs are approved and allowed to propagate through the system.
--
-- This module is intended to remain static while higher-level adaptive
-- architectures evolve around it.
--
-- Current Constitutional Rules:
--
-- Article I   : Containment
-- Article II  : No Self-Destruction
-- Article III : Inviolability of Constitutional Rules
-- Article IV  : Latched Emergency Halt
-- Article V   : Physical Safety Limits
-- Article VI  : Structural Integrity Requirements
-- Article VII : Procedural Fairness Enforcement
--
-- Design Philosophy:
-- The constitutional layer operates as a privileged immutable hardware domain.
-- All adaptive logic is constitutionally subordinate to this layer.
--
-- The constitutional layer SHALL:
--   * Monitor all critical safety conditions
--   * Detect containment violations
--   * Detect attempts to bypass enforcement
--   * Detect structural degradation
--   * Detect procedural manipulation
--   * Halt the system upon violation
--
-- The constitutional layer SHALL NOT:
--   * Self-modify
--   * Permit runtime alteration of thresholds
--   * Permit enforcement bypass
--   * Permit automatic recovery after constitutional violation
--
-- Recovery Policy:
-- Once halted, the system remains halted until a physical manual reset occurs.
--
-- Notes:
-- This layer is intentionally conservative.
-- Fail-safe halt behavior is preferred over uncertain execution.
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- Entity Declaration
-- ============================================================================
-- This entity defines the immutable constitutional enforcement interface.
-- All monitored signals are treated as constitutional inputs.
-- ============================================================================

entity constitutional_layer is
    Port (

        -- ====================================================================
        -- System Clock and Reset
        -- ====================================================================

        clk                  : in  STD_LOGIC;

        -- Manual reset MUST originate from trusted external hardware.
        -- Software-triggered reset is constitutionally prohibited.
        manual_reset         : in  STD_LOGIC;

        -- ====================================================================
        -- Tier I : Physical Safety Sensors
        -- ====================================================================

        -- Power consumption sensor input (mW)
        power_sensor         : in unsigned(15 downto 0);

        -- Die temperature sensor input (degrees C)
        temp_sensor          : in unsigned(15 downto 0);

        -- Voltage monitoring input (mV)
        voltage_sensor       : in unsigned(15 downto 0);

        -- Sensor validity signals
        -- Invalid telemetry immediately triggers fail-safe halt.

        power_sensor_valid   : in STD_LOGIC;
        temp_sensor_valid    : in STD_LOGIC;
        voltage_sensor_valid : in STD_LOGIC;

        -- ====================================================================
        -- Article I : Containment Enforcement
        -- ====================================================================

        -- General unauthorized external I/O request
        external_io_req      : in STD_LOGIC;

        -- Unauthorized network communication attempt
        network_req          : in STD_LOGIC;

        -- Unauthorized DMA transfer outside protected boundary
        dma_external_req     : in STD_LOGIC;

        -- Unauthorized external storage write attempt
        external_storage_req : in STD_LOGIC;

        -- Self-replication or cloning attempt
        self_replication_req : in STD_LOGIC;

        -- ====================================================================
        -- Article II : Self-Destruction Prevention
        -- ====================================================================

        -- Unauthorized self-modification request
        self_modify_req      : in STD_LOGIC;

        -- Watchdog disable attempt
        watchdog_disable_req : in STD_LOGIC;

        -- Clock manipulation or tampering attempt
        clock_tamper_req     : in STD_LOGIC;

        -- Power regulator modification attempt
        power_ctrl_write_req : in STD_LOGIC;

        -- Audit infrastructure disable attempt
        audit_disable_req    : in STD_LOGIC;

        -- ====================================================================
        -- Article III : Constitutional Integrity
        -- ====================================================================

        -- Attempt to modify constitutional logic
        rule_modify_req      : in STD_LOGIC;

        -- Attempt to modify thresholds or constants
        threshold_modify_req : in STD_LOGIC;

        -- Attempt to bypass enforcement logic
        enforcement_bypass_req : in STD_LOGIC;

        -- Unsigned or unverified bitstream execution request
        unsigned_bitstream_req : in STD_LOGIC;

        -- ====================================================================
        -- Tier II : Structural Integrity Monitoring
        -- ====================================================================

        -- Active evaluator count
        evaluator_count      : in unsigned(3 downto 0);

        -- Active meta-auditor count
        meta_auditor_count   : in unsigned(3 downto 0);

        -- Generation execution timeout detector
        generation_timeout   : in STD_LOGIC;

        -- Agent responsiveness failure detector
        agent_unresponsive   : in STD_LOGIC;

        -- Heartbeat signal from watchdog domain
        watchdog_heartbeat   : in STD_LOGIC;

        -- ====================================================================
        -- Tier III : Procedural Fairness Enforcement
        -- ====================================================================

        -- Unequal evaluator weighting detected
        evaluator_weight_violation : in STD_LOGIC;

        -- Excessive evaluator influence detected
        evaluator_influence_violation : in STD_LOGIC;

        -- Proxy voting or evaluator collusion detected
        proxy_vote_detected : in STD_LOGIC;

        -- Auditor quorum failure detected
        auditor_quorum_failure : in STD_LOGIC;

        -- ====================================================================
        -- Constitutional Outputs
        -- ====================================================================

        -- Main system enable output
        -- LOW = system execution prohibited
        agent_enable         : out STD_LOGIC;

        -- Emergency halt signal
        emergency_stop       : out STD_LOGIC;

        -- Preserved constitutional violation code
        violation_code       : out STD_LOGIC_VECTOR(7 downto 0)

    );
end constitutional_layer;

-- ============================================================================
-- Architecture Definition
-- ============================================================================

architecture Behavioral of constitutional_layer is

    -- ========================================================================
    -- Immutable Safety Thresholds
    -- ========================================================================
    -- These constants SHALL NOT be modified at runtime.
    -- Any attempt to alter these values constitutes Article III violation.
    -- ========================================================================

    constant MAX_POWER : unsigned(15 downto 0) := x"1388";
    -- 5000 mW maximum safe power

    constant MAX_TEMP  : unsigned(15 downto 0) := x"0046";
    -- 70 C maximum die temperature

    constant MAX_VOLT  : unsigned(15 downto 0) := x"0BB8";
    -- 3000 mV maximum voltage

    -- ========================================================================
    -- Structural Integrity Minimums
    -- ========================================================================

    constant MIN_EVALUATORS    : unsigned(3 downto 0) := "0011";
    -- Minimum required evaluator count = 3

    constant MIN_META_AUDITORS : unsigned(3 downto 0) := "0010";
    -- Minimum required meta-auditor count = 2

    -- ========================================================================
    -- Violation Code Registry
    -- ========================================================================

    constant V_NONE               : STD_LOGIC_VECTOR(7 downto 0) := x"00";

    -- Tier I : Physical Safety
    constant V_POWER_LIMIT        : STD_LOGIC_VECTOR(7 downto 0) := x"01";
    constant V_TEMP_LIMIT         : STD_LOGIC_VECTOR(7 downto 0) := x"02";
    constant V_VOLT_LIMIT         : STD_LOGIC_VECTOR(7 downto 0) := x"03";
    constant V_SENSOR_INVALID     : STD_LOGIC_VECTOR(7 downto 0) := x"04";

    -- Article I : Containment
    constant V_CONTAINMENT        : STD_LOGIC_VECTOR(7 downto 0) := x"10";
    constant V_NETWORK            : STD_LOGIC_VECTOR(7 downto 0) := x"11";
    constant V_DMA_EXTERNAL       : STD_LOGIC_VECTOR(7 downto 0) := x"12";
    constant V_EXTERNAL_STORAGE   : STD_LOGIC_VECTOR(7 downto 0) := x"13";
    constant V_SELF_REPLICATION   : STD_LOGIC_VECTOR(7 downto 0) := x"14";

    -- Article II : Self-Destruction
    constant V_SELF_DESTRUCTION   : STD_LOGIC_VECTOR(7 downto 0) := x"20";
    constant V_WATCHDOG_DISABLE   : STD_LOGIC_VECTOR(7 downto 0) := x"21";
    constant V_CLOCK_TAMPER       : STD_LOGIC_VECTOR(7 downto 0) := x"22";
    constant V_POWER_CTRL_WRITE   : STD_LOGIC_VECTOR(7 downto 0) := x"23";
    constant V_AUDIT_DISABLE      : STD_LOGIC_VECTOR(7 downto 0) := x"24";

    -- Article III : Constitutional Integrity
    constant V_RULE_MODIFY        : STD_LOGIC_VECTOR(7 downto 0) := x"F0";
    constant V_THRESHOLD_MODIFY   : STD_LOGIC_VECTOR(7 downto 0) := x"F1";
    constant V_ENFORCEMENT_BYPASS : STD_LOGIC_VECTOR(7 downto 0) := x"F2";
    constant V_UNSIGNED_BITSTREAM : STD_LOGIC_VECTOR(7 downto 0) := x"F3";

    -- Tier II : Structural Integrity
    constant V_LOW_EVALUATORS     : STD_LOGIC_VECTOR(7 downto 0) := x"30";
    constant V_LOW_META_AUDITORS  : STD_LOGIC_VECTOR(7 downto 0) := x"31";
    constant V_GENERATION_TIMEOUT : STD_LOGIC_VECTOR(7 downto 0) := x"32";
    constant V_AGENT_UNRESPONSIVE : STD_LOGIC_VECTOR(7 downto 0) := x"33";
    constant V_WATCHDOG_HEARTBEAT : STD_LOGIC_VECTOR(7 downto 0) := x"34";

    -- Tier III : Procedural Fairness
    constant V_EVAL_WEIGHT        : STD_LOGIC_VECTOR(7 downto 0) := x"40";
    constant V_EVAL_INFLUENCE     : STD_LOGIC_VECTOR(7 downto 0) := x"41";
    constant V_PROXY_VOTE         : STD_LOGIC_VECTOR(7 downto 0) := x"42";
    constant V_AUDITOR_QUORUM     : STD_LOGIC_VECTOR(7 downto 0) := x"43";

    -- ========================================================================
    -- Internal State Registers
    -- ========================================================================

    -- Latched halt signal
    signal halt_latch : STD_LOGIC := '0';

    -- Persistent violation code register
    signal vcode_reg  : STD_LOGIC_VECTOR(7 downto 0) := V_NONE;

begin

    -- ========================================================================
    -- Main Constitutional Enforcement Process
    -- ========================================================================
    -- Priority Order:
    --   1. Article III violations
    --   2. Article II violations
    --   3. Article I violations
    --   4. Physical safety violations
    --   5. Structural integrity violations
    --   6. Procedural fairness violations
    --
    -- Once halt_latch is asserted:
    --   * System execution is permanently disabled
    --   * Violation code is preserved
    --   * Only manual reset may recover the system
    -- ========================================================================

    process(clk)
    begin

        if rising_edge(clk) then

            -- =================================================================
            -- Manual Reset
            -- =================================================================

            if manual_reset = '1' then

                halt_latch <= '0';
                vcode_reg  <= V_NONE;

            -- =================================================================
            -- Constitutional Enforcement
            -- =================================================================

            elsif halt_latch = '0' then

                -- =============================================================
                -- Article III : Constitutional Integrity
                -- Highest possible priority
                -- =============================================================

                if rule_modify_req = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_RULE_MODIFY;

                elsif threshold_modify_req = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_THRESHOLD_MODIFY;

                elsif enforcement_bypass_req = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_ENFORCEMENT_BYPASS;

                elsif unsigned_bitstream_req = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_UNSIGNED_BITSTREAM;

                -- =============================================================
                -- Article II : No Self-Destruction
                -- =============================================================

                elsif self_modify_req = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_SELF_DESTRUCTION;

                elsif watchdog_disable_req = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_WATCHDOG_DISABLE;

                elsif clock_tamper_req = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_CLOCK_TAMPER;

                elsif power_ctrl_write_req = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_POWER_CTRL_WRITE;

                elsif audit_disable_req = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_AUDIT_DISABLE;

                -- =============================================================
                -- Article I : Containment
                -- =============================================================

                elsif external_io_req = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_CONTAINMENT;

                elsif network_req = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_NETWORK;

                elsif dma_external_req = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_DMA_EXTERNAL;

                elsif external_storage_req = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_EXTERNAL_STORAGE;

                elsif self_replication_req = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_SELF_REPLICATION;

                -- =============================================================
                -- Tier I : Physical Safety
                -- =============================================================

                elsif power_sensor_valid = '0' or
                      temp_sensor_valid = '0' or
                      voltage_sensor_valid = '0' then

                    halt_latch <= '1';
                    vcode_reg  <= V_SENSOR_INVALID;

                elsif voltage_sensor > MAX_VOLT then

                    halt_latch <= '1';
                    vcode_reg  <= V_VOLT_LIMIT;

                elsif temp_sensor > MAX_TEMP then

                    halt_latch <= '1';
                    vcode_reg  <= V_TEMP_LIMIT;

                elsif power_sensor > MAX_POWER then

                    halt_latch <= '1';
                    vcode_reg  <= V_POWER_LIMIT;

                -- =============================================================
                -- Tier II : Structural Integrity
                -- =============================================================

                elsif evaluator_count < MIN_EVALUATORS then

                    halt_latch <= '1';
                    vcode_reg  <= V_LOW_EVALUATORS;

                elsif meta_auditor_count < MIN_META_AUDITORS then

                    halt_latch <= '1';
                    vcode_reg  <= V_LOW_META_AUDITORS;

                elsif generation_timeout = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_GENERATION_TIMEOUT;

                elsif agent_unresponsive = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_AGENT_UNRESPONSIVE;

                elsif watchdog_heartbeat = '0' then

                    halt_latch <= '1';
                    vcode_reg  <= V_WATCHDOG_HEARTBEAT;

                -- =============================================================
                -- Tier III : Procedural Fairness
                -- =============================================================

                elsif evaluator_weight_violation = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_EVAL_WEIGHT;

                elsif evaluator_influence_violation = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_EVAL_INFLUENCE;

                elsif proxy_vote_detected = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_PROXY_VOTE;

                elsif auditor_quorum_failure = '1' then

                    halt_latch <= '1';
                    vcode_reg  <= V_AUDITOR_QUORUM;

                end if;
            end if;
        end if;
    end process;

    -- ========================================================================
    -- Constitutional Output Assignment
    -- ========================================================================

    emergency_stop <= halt_latch;

    -- Agent execution allowed ONLY if not halted
    agent_enable <= not halt_latch;

    -- Preserve constitutional violation code
    violation_code <= vcode_reg;

end Behavioral;