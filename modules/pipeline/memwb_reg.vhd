use work.parameters.REGISTER_ADDRESS_WIDTH;
use work.parameters.DATA_WORD_SIZE;

entity memwb_reg is
    port(
        clock, reset,
        -- Input
        in_memToReg,
        in_regWrite: in bit;
        in_dmOut,
        in_aluResult: in bit_vector(DATA_WORD_SIZE-1 downto 0);
        in_rd: in bit_vector(REGISTER_ADDRESS_WIDTH-1 downto 0);
        -- Output
        out_memToReg,
        out_regWrite: out bit;
        out_dmOut,
        out_aluResult: out bit_vector(DATA_WORD_SIZE-1 downto 0);
        out_rd: out bit_vector(REGISTER_ADDRESS_WIDTH-1 downto 0)
    );
end entity;

architecture arch of memwb_reg is
    component ff is
        port(
            clock, reset, enable, wr: in bit;
            dataIn: in bit;
            dataOut: out bit
        );
    end component;

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

    memToReg_reg: ff
        port map(
            clock, reset, '1', '1',
            in_memToReg, out_memToReg
        );

    regWrite_reg: ff
        port map(
            clock, reset, '1', '1',
            in_regWrite, out_regWrite
        );

    dmOut_reg: reg
        generic map(DATA_WORD_SIZE)
        port map(
            clock, reset, '1', '1',
            in_dmOut, out_dmOut
        );

    aluResult_reg: reg
        generic map(DATA_WORD_SIZE)
        port map(
            clock, reset, '1', '1',
            in_aluResult, out_aluResult
        );

    rd_reg: reg
        generic map(REGISTER_ADDRESS_WIDTH)
        port map(
            clock, reset, '1', '1',
            in_rd, out_rd
        );

end arch;
