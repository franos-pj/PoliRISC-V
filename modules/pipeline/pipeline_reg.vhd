entity pipeline_reg is
    generic(
        wordSize: natural := 64
    );
    port(
        clock, reset: in bit;
        dataIn: in bit_vector(wordSize-1 downto 0);
        dataOut: out bit_vector(wordSize-1 downto 0)
    );
end entity;

architecture arch of pipeline_reg is
    component reg is
        generic(
            wordSize: natural := 64
        );
        port(
            clock, reset, enable, wr: in bit;
            dataIn: in bit_vector(wordSize-1 downto 0);
            dataOut: out bit_vector(wordSize-1 downto 0)
        );
    end component;
begin
    alwaysWriteReg: reg
        generic map(wordSize)
        port map(
            clock,
            reset, '1', '1',
            dataIn, dataOut
        );
end architecture arch;
