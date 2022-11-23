use work.parameters.REGISTER_ADDRESS_WIDTH;
use work.parameters.DATA_WORD_SIZE;

entity idex_reg is
    port(
        clock, reset,
        -- Input
        in_memToReg,
        in_regWrite,
        in_branch,
        in_memRead,
        in_memWrite: in bit;
        in_funct3: in bit_vector(2 downto 0);
        in_funct7_5,
        in_aluSrc: in bit;
        in_aluOpIn: in bit_vector(1 downto 0);
        in_q1,
        in_q2,
        in_signExtendOut: in bit_vector(DATA_WORD_SIZE-1 downto 0);
        in_rs1,
        in_rs2,
        in_rd: in bit_vector(REGISTER_ADDRESS_WIDTH-1 downto 0);
        -- Output
        out_memToReg,
        out_regWrite,
        out_branch,
        out_memRead,
        out_memWrite: out bit;
        out_funct3: out bit_vector(2 downto 0);
        out_funct7_5,
        out_aluSrc: out bit;
        out_aluOpIn: out bit_vector(1 downto 0);
        out_q1,
        out_q2,
        out_signExtendOut: out bit_vector(DATA_WORD_SIZE-1 downto 0);
        out_rs1,
        out_rs2,
        out_rd: out bit_vector(REGISTER_ADDRESS_WIDTH-1 downto 0)
    );
end entity;

architecture arch of idex_reg is
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

    funct3_reg: reg
        generic map(3)
        port map(
            clock, reset, '1', '1',
            in_funct3, out_funct3
        );

    funct7_5_reg: ff
        port map(
            clock, reset, '1', '1',
            in_funct7_5, out_funct7_5
        );

    aluSrc_reg: ff
        port map(
            clock, reset, '1', '1',
            in_aluSrc, out_aluSrc
        );

    aluOpIn_reg: reg
        generic map(2)
        port map(
            clock, reset, '1', '1',
            in_aluOpIn, out_aluOpIn
        );

    q1_reg: reg
        generic map(DATA_WORD_SIZE)
        port map(
            clock, reset, '1', '1',
            in_q1, out_q1
        );

    q2_reg: reg
        generic map(DATA_WORD_SIZE)
        port map(
            clock, reset, '1', '1',
            in_q2, out_q2
        );

    signExtendOut_reg: reg
        generic map(DATA_WORD_SIZE)
        port map(
            clock, reset, '1', '1',
            in_signExtendOut, out_signExtendOut
        );

    rs1_reg: reg
        generic map(REGISTER_ADDRESS_WIDTH)
        port map(
            clock, reset, '1', '1',
            in_rs1, out_rs1
        );

    rs2_reg: reg
        generic map(REGISTER_ADDRESS_WIDTH)
        port map(
            clock, reset, '1', '1',
            in_rs2, out_rs2
        );

    rd_reg: reg
        generic map(REGISTER_ADDRESS_WIDTH)
        port map(
            clock, reset, '1', '1',
            in_rd, out_rd
        );


end arch;
