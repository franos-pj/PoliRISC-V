use work.utils.all;

entity signExtend_tb is
end entity;

architecture arch of signExtend_tb is

    component signExtend is
        generic (
            inputSize: natural := 32;
            outputSize: natural := 64
        );
        port(
            i: in  bit_vector(inputSize-1 downto 0);
            o: out bit_vector(outputSize-1 downto 0)
        );
    end component;

    type test_case_type is record
        stimulus: bit_vector(31 downto 0);
        response: bit_vector(63 downto 0);
    end record;

    -- RISC-V INSTRUCTION FORMATS --
    --- I-type (lw) ---
    ----                       funct3      opcode
    ----                          v          v
    ----     |     imm    | rs1 |   | rd  |      |
    --- S-type ---
    ----     imm[11:5]        funct3 imm[4:0] opcode
    ----         v                 v    v      v
    ----     |       | rs2 | rs1 |   |     |      |
    -- --

    type test_case_array is array(0 to 5) of test_case_type;

    constant TEST_CASES: test_case_array := (
        ( -- lw with positive immediate
            B"000000000001_00000_000_00000_0000011",
            B"0000000000000000000000000000000000000000000000000000_000000000001"),
        ( -- lw with negative immediate
            B"100000000001_00000_000_00000_0000011",
            B"1111111111111111111111111111111111111111111111111111_100000000001"),
        ( -- sw with positive immediate
            B"0000000_00000_00000_000_00001_0100011",
            B"0000000000000000000000000000000000000000000000000000_000000000001"),
        ( -- sw with negative immediate
            B"1000000_00000_00000_000_00001_0100011",
            B"1111111111111111111111111111111111111111111111111111_100000000001"),
        ( -- beq with positive immediate
            B"0000000_00000_00000_000_00001_1100011",
            B"0000000000000000000000000000000000000000000000000000_000000000001"),
        ( -- beq with negative immediate
            B"1000000_00000_00000_000_00001_1100011",
            B"1111111111111111111111111111111111111111111111111111_100000000001")
    );

    signal i: bit_vector(31 downto 0);
    signal o: bit_vector(63 downto 0);

begin

	dut: signExtend port map(i, o);

	tb: process
	begin
		report "BOT";

        for index in TEST_CASES'range loop
            i <= TEST_CASES(index).stimulus;
            wait for 1 ps;
            assert_equals(TEST_CASES(index).response, o, index);
        end loop;

		report "EOT";
		wait;
	end process;

end architecture arch;
