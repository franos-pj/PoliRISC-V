library ieee;
use ieee.numeric_std.std_match;
use ieee.std_logic_1164.all;

use work.utils.all;

entity alucontrol_tb is
end entity;

architecture arch of alucontrol_tb is

    component alucontrol is
        port(
            funct3   : in  bit_vector (2 downto 0);
            funct7_5 : in  bit;
            aluOp    : in  bit_vector (1 downto 0);
            aluCtrl  : out bit_vector (3 downto 0)
        );
    end component;

    type test_case_type is record
        funct3   : std_logic_vector (2 downto 0);
        funct7_5 : std_logic;
        aluOp    : bit_vector (1 downto 0);
        response : bit_vector (3 downto 0);
    end record;
    type test_case_array is array(1 to 7) of test_case_type;
    constant TEST_CASES: test_case_array := (
        ("---", '-', "00", "0010"), -- lw
        ("---", '-', "00", "0010"), -- sw
        ("---", '-', "01", "0110"), -- beq
        ("000", '0', "10", "0010"), -- add (R-type)
        ("000", '1', "10", "0110"), -- sub (R-type)
        ("111", '0', "10", "0000"), -- and (R-type)
        ("110", '0', "10", "0001")  -- or  (R-type)
    );

    signal funct3   : bit_vector (2 downto 0);
    signal funct7_5 : bit;
    signal aluOp    : bit_vector (1 downto 0);
    signal response : bit_vector (3 downto 0);

begin

	dut: alucontrol 
    port map(
        funct3, 
        funct7_5,
        aluOp, 
        response
    );

	tb: process
	begin
		report "BOT";

        for index in TEST_CASES'range loop
            funct3   <= to_bitvector(TEST_CASES(index).funct3);
            funct7_5 <= to_bit(TEST_CASES(index).funct7_5);
            aluOp    <= TEST_CASES(index).aluOp;
            wait for 1 ps;
            assert_equals(TEST_CASES(index).response, response, index);
        end loop;

		report "EOT";
		wait;
	end process;

end architecture arch;
