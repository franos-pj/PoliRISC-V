use work.utils.all;

entity Shiftleft2_tb is
end entity;

architecture arch of Shiftleft2_tb is

    component Shiftleft2 is
        generic (
            inputSize: natural := 64;
            outputSize: natural := 64
        );
        port(
            i: in bit_vector(inputSize-1 downto 0);
            o: out bit_vector(outputSize-1 downto 0)
        );
    end component Shiftleft2;


    type test_case_type is record
        stimulus: bit_vector(63 downto 0);
        response: bit_vector(63 downto 0);
    end record;
    type test_case_array is array(1 to 5) of test_case_type;
    constant TEST_CASES: test_case_array := (
        (
            "1000000000000000000000000000000000000000000000000000000000000001",
            "0000000000000000000000000000000000000000000000000000000000000100"
        ),
        (
            "1000000000000000000000000000000000000000000000000000000000000011",
            "0000000000000000000000000000000000000000000000000000000000001100"
        ),
        (
            "1100000000000000000000000000000000000000000000000000000000000001",
            "0000000000000000000000000000000000000000000000000000000000000100"
        ),
        (
            "1000000000000001000000000000010000000000001000000010000000000001",
            "0000000000000100000000000001000000000000100000001000000000000100"

        ),
        (
            "1111000000000000000000000000000000000000000000000000000000000001",
            "1100000000000000000000000000000000000000000000000000000000000100"
        )
    );

    signal i, o: bit_vector(63 downto 0);

begin

    dut: Shiftleft2 port map(i, o);

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
