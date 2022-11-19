library ieee;
use ieee.numeric_std.std_match;
use ieee.std_logic_1164.all;

use work.utils.all;

entity controlunit_tb is
end entity;

architecture arch of controlunit_tb is

    component controlunit is
        port(
            --- From Datapath ---
            opcode   : in  bit_vector (6 downto 0);
            --- To   Datapath ---
            -- ID stage
            regWrite : out bit;
            -- EX stage
            aluSrc   : out bit;
            aluOp    : out bit_vector (1 downto 0);
            -- MEM stage
            branch   : out bit;
            memRead  : out bit;
            memWrite : out bit;
            -- WB stage
            memToReg : out bit
        );
    end component;

    type test_case_type is record
        stimulus: std_logic_vector(6 downto 0);
        response: std_logic_vector(7 downto 0);
    end record;
    type test_case_array is array(1 to 4) of test_case_type;
    constant TEST_CASES: test_case_array := (
        ( -- R-format
            "0110011",
            "10100000"),
        ( -- lw
            "0000011",
            "11000101"),
        ( -- sw
            "0100011",
            "0100001-"),
        ( -- beq
            "1100011",
            "0001100-")
    );

    signal opcode: bit_vector(6 downto 0);
    signal controlSignals: bit_vector(7 downto 0);

begin

	dut: controlunit port map(
        opcode,
        controlSignals(7),          -- regWrite
        controlSignals(6),          -- aluSrc
        controlSignals(5 downto 4), -- aluOp
        controlSignals(3),          -- branch
        controlSignals(2),          -- memRead
        controlSignals(1),          -- memWrite
        controlSignals(0)           -- memToReg
    );

	tb: process
	begin
		report "BOT";

        for index in TEST_CASES'range loop
            opcode <= to_bitvector(TEST_CASES(index).stimulus);
            wait for 1 ps;
            assert_equals(TEST_CASES(index).response, controlSignals, index);
        end loop;

		report "EOT";
		wait;
	end process;

end architecture arch;
