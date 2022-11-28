entity signExtend is
    generic (
        inputSize: natural := 32;
        outputSize: natural := 64
    );
    port(
        i: in  bit_vector(inputSize-1 downto 0);
        o: out bit_vector(outputSize-1 downto 0)
    );
end signExtend;

architecture combinational of signExtend is
    subtype opcode_t is bit_vector(6 downto 0);

    signal opcode: opcode_t;
    signal toExtend: bit_vector(11 downto 0);

    constant LW_OPCODE: opcode_t := B"000_0011";
    constant SW_OPCODE: opcode_t := B"010_0011";
    constant BEQ_OPCODE: opcode_t := B"110_0011";
begin
    opcode <= i(opcode'range);
    with opcode select toExtend <=
        i(31 downto 20) when LW_OPCODE,
        i(31 downto 25) & i(11 downto 7) when SW_OPCODE,
        i(31 downto 25) & i(11 downto 7) when BEQ_OPCODE,
        (others => '0') when others;

    o <= ((outputSize - toExtend'length)-1 downto 0 => toExtend(toExtend'left)) & toExtend;

end architecture combinational;
