use work.parameters.REGISTER_ADDRESS_WIDTH;
use work.parameters.DATA_WORD_SIZE;

entity exmem_reg is
    port(
        clock, reset: in bit;
        -- Input
        in_memToReg,
        in_regWrite,
        in_branch,
        in_memRead,
        in_memWrite,
        in_aluZero: in bit;
        in_result,
        in_q2: in bit_vector(DATA_WORD_SIZE-1 downto 0);
        in_rd: in bit_vector(REGISTER_ADDRESS_WIDTH-1 downto 0);
        -- Output
        out_memToReg,
        out_regWrite,
        out_branch,
        out_memRead,
        out_memWrite,
        out_aluZero: out bit;
        out_result,
        out_q2: out bit_vector(DATA_WORD_SIZE-1 downto 0);
        out_rd: out bit_vector(REGISTER_ADDRESS_WIDTH-1 downto 0)
    );
end entity;

architecture arch of exmem_reg is
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

    branch_reg: ff
        port map(
            clock, reset, '1', '1',
            in_branch, out_branch
        );

    memRead_reg: ff
        port map(
            clock, reset, '1', '1',
            in_memRead, out_memRead
        );

    memWrite_reg: ff
        port map(
            clock, reset, '1', '1',
            in_memWrite, out_memWrite
        );

    aluZero_reg: ff
        port map(
            clock, reset, '1', '1',
            in_aluZero, out_aluZero
        );

    result_reg: reg
        generic map(DATA_WORD_SIZE)
        port map(
            clock, reset, '1', '1',
            in_result, out_result
        );

    q2_reg: reg
        generic map(DATA_WORD_SIZE)
        port map(
            clock, reset, '1', '1',
            in_q2, out_q2
        );

    rd_reg: reg
        generic map(REGISTER_ADDRESS_WIDTH)
        port map(
            clock, reset, '1', '1',
            in_rd, out_rd
        );


end arch;
