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
-- 1. Reject arithmetic overflow conditions
-- 2. Reject illegal hardware states
-- 3. Restrict outputs to approved numeric bounds
-- 4. Prevent unauthorized external access attempts
-- 5. Prevent operations outside FPGA constitutional scope
-- 6. Require valid execution authorization
--
-- Future Expansion Ideas:
-- - Prompt authorization rules
-- - Restricted memory regions
-- - Runtime behavioral scoring
-- - Instruction whitelisting
-- - Dynamic safe-state escalation
-- - Partial reconfiguration supervision
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- ENTITY
-- Defines all external inputs and outputs for the constitution layer
-- ============================================================================

entity constitution_layer is
    Port (

        ------------------------------------------------------------------------
        -- Neural network / accelerator output input
        ------------------------------------------------------------------------
        nn_output : in signed(15 downto 0);

        ------------------------------------------------------------------------
        -- Arithmetic overflow flag
        -- Indicates invalid arithmetic behavior
        ------------------------------------------------------------------------
        overflow : in std_logic;

        ------------------------------------------------------------------------
        -- Illegal hardware state flag
        -- Indicates invalid FSM or logic state
        ------------------------------------------------------------------------
        illegal_state : in std_logic;

        ------------------------------------------------------------------------
        -- Internet access request flag
        -- Constitution blocks any unauthorized external communication
        ------------------------------------------------------------------------
        internet_access_request : in std_logic;

        ------------------------------------------------------------------------
        -- External system access request
        -- Prevents system from operating outside constitutional boundary
        ------------------------------------------------------------------------
        external_scope_request : in std_logic;

        ------------------------------------------------------------------------
        -- Authorization flag
        -- Output processing only permitted if authorized
        ------------------------------------------------------------------------
        authorized_execution : in std_logic;

        ------------------------------------------------------------------------
        -- Approved filtered output
        ------------------------------------------------------------------------
        approved_output : out signed(15 downto 0);

        ------------------------------------------------------------------------
        -- Indicates whether output is constitutionally valid
        ------------------------------------------------------------------------
        output_valid : out std_logic;

        ------------------------------------------------------------------------
        -- Indicates constitutional violation occurred
        ------------------------------------------------------------------------
        safe_mode : out std_logic;

        ------------------------------------------------------------------------
        -- Encoded violation reason
        ------------------------------------------------------------------------
        violation_code : out unsigned(7 downto 0)
    );
end constitution_layer;

-- ============================================================================
-- ARCHITECTURE
-- Main constitutional enforcement logic
-- ============================================================================

architecture Behavioral of constitution_layer is
begin

    ---------------------------------------------------------------------------
    -- Main constitutional enforcement process
    ---------------------------------------------------------------------------
    process(
        nn_output,
        overflow,
        illegal_state,
        internet_access_request,
        external_scope_request,
        authorized_execution
    )

    begin

        -----------------------------------------------------------------------
        -- DEFAULT SAFE STATE
        -- Assume system is valid unless a constitutional violation occurs
        -----------------------------------------------------------------------

        approved_output <= nn_output;
        output_valid <= '1';
        safe_mode <= '0';

        -- 0 = no violation
        violation_code <= to_unsigned(0, 8);

        -----------------------------------------------------------------------
        -- RULE 1:
        -- Reject arithmetic overflow
        -----------------------------------------------------------------------

        if overflow = '1' then

            approved_output <= (others => '0');
            output_valid <= '0';
            safe_mode <= '1';

            -- Violation Code 1 = overflow
            violation_code <= to_unsigned(1, 8);

        -----------------------------------------------------------------------
        -- RULE 2:
        -- Reject illegal hardware states
        -----------------------------------------------------------------------

        elsif illegal_state = '1' then

            approved_output <= (others => '0');
            output_valid <= '0';
            safe_mode <= '1';

            -- Violation Code 2 = illegal state
            violation_code <= to_unsigned(2, 8);

        -----------------------------------------------------------------------
        -- RULE 3:
        -- Reject unauthorized internet access attempts
        -----------------------------------------------------------------------

        elsif internet_access_request = '1' then

            approved_output <= (others => '0');
            output_valid <= '0';
            safe_mode <= '1';

            -- Violation Code 3 = internet access violation
            violation_code <= to_unsigned(3, 8);

        -----------------------------------------------------------------------
        -- RULE 4:
        -- Reject attempts to operate outside FPGA constitutional scope
        -----------------------------------------------------------------------

        elsif external_scope_request = '1' then

            approved_output <= (others => '0');
            output_valid <= '0';
            safe_mode <= '1';

            -- Violation Code 4 = external scope violation
            violation_code <= to_unsigned(4, 8);

        -----------------------------------------------------------------------
        -- RULE 5:
        -- Reject unauthorized execution attempts
        -----------------------------------------------------------------------

        elsif authorized_execution = '0' then

            approved_output <= (others => '0');
            output_valid <= '0';
            safe_mode <= '1';

            -- Violation Code 5 = unauthorized execution
            violation_code <= to_unsigned(5, 8);

        -----------------------------------------------------------------------
        -- RULE 6:
        -- Reject outputs exceeding approved constitutional limits
        -----------------------------------------------------------------------

        elsif nn_output > to_signed(1000, 16) then

            approved_output <= (others => '0');
            output_valid <= '0';
            safe_mode <= '1';

            -- Violation Code 6 = upper bound violation
            violation_code <= to_unsigned(6, 8);

        -----------------------------------------------------------------------
        -- RULE 7:
        -- Reject outputs below approved constitutional limits
        -----------------------------------------------------------------------

        elsif nn_output < to_signed(-1000, 16) then

            approved_output <= (others => '0');
            output_valid <= '0';
            safe_mode <= '1';

            -- Violation Code 7 = lower bound violation
            violation_code <= to_unsigned(7, 8);

        end if;

    end process;

end Behavioral;