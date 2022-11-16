library ieee;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.numeric_bit.all;

use work.parameters.NUMBER_OF_REGISTERS;
use work.parameters.REGISTER_ADDRESS_WIDTH;
use work.parameters.DATA_WORD_SIZE;
use work.parameters.INSTRUCTION_WORD_SIZE;
use work.pipeline.all;

entity datapath is
    port(
        -- Common
        clock,
        reset,
        -- From Control Unit
        reg2loc,
        pcSrc,
        memToReg: in bit;
        aluCtrl: in bit_vector(3 downto 0);
        aluSrc,
        regWrite: in bit;
        -- To Control Unit
        opcode: out bit_vector(6 downto 0);
        funct3: out bit_vector(2 downto 0);
        zero: out bit;
        -- IM interface
        imAddr: out bit_vector(63 downto 0);
        imOut: in bit_vector(31 downto 0);
        -- DM interface
        dmAddr,
        dmIn: out bit_vector(63 downto 0);
        dmOut: in bit_vector(63 downto 0);

        -- Pipeline control signals
        --- Hazard detection unit
        pcWrite: in bit;
        ---- Data hazard
        idexDisable: in bit;
        ---- Control hazard
        registersEqual: out bit;
        ifidFlush: in bit
    );
end entity datapath;

architecture arch of datapath is

    component regfile is
        generic(
            regn: natural := 32;
            wordSize: natural := 64
        );
        port(
            clock, reset, regWrite: in bit;
            rr1, rr2, wr: in bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
            d: in bit_vector(wordSize-1 downto 0);
            q1, q2: out bit_vector(wordSize-1 downto 0)
        );
    end component;

    component alu is
        generic(
            size: natural := 10
        );
        port(
            A, B: in bit_vector(size-1 downto 0);
            F: out bit_vector(size-1 downto 0);
            S: in bit_vector(3 downto 0);
            Z, Ov, Co: out bit
        );
    end component;

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

    constant REGISTER_ADDR_SIZE: natural := REGISTER_ADDRESS_WIDTH;
    constant WORD_SIZE: natural := DATA_WORD_SIZE;
    constant INSTRUCTION_SIZE: natural := INSTRUCTION_WORD_SIZE;

    signal rr1, rr2, rd, wr: bit_vector(REGISTER_ADDR_SIZE-1 downto 0);
    signal q1, q2, d: bit_vector(WORD_SIZE-1 downto 0);

    signal dataAluA, dataAluB, dataAluResult: bit_vector(WORD_SIZE-1 downto 0);
    signal dataOverflow, dataCarryOut: bit;

    signal signExtendOut: bit_vector(WORD_SIZE-1 downto 0);

    signal pcPlusFour: bit_vector(WORD_SIZE-1 downto 0);

    signal shiftOut: bit_vector(WORD_SIZE-1 downto 0);

    signal pcPlusShift: bit_vector(WORD_SIZE-1 downto 0);

    signal pcIn, pcOut: bit_vector(WORD_SIZE-1 downto 0);


    component pipeline_reg is
        generic(
            wordSize: natural := 64
        );
        port(
            clock, reset: in bit;
            dataIn: in bit_vector(wordSize-1 downto 0);
            dataOut: out bit_vector(wordSize-1 downto 0)
        );
    end component;

    constant NOP: bit_vector(31 downto 0) := x"00000013";

    signal aluZero: bit;

    signal ifidIn, ifidOut: ifid_t;
    signal idexOut: idex_t;
    signal exmemOut: exmem_t;
    signal memwbOut: memwb_t;

    signal idexInBv, idexOutBv: bit_vector(
        (
            WB_CONTROL_WIDTH
            + M_CONTROL_WIDTH
            + EX_CONTROL_WIDTH
            + 3*DATA_WORD_SIZE -- q1, q2, immExtended
            + REGISTER_ADDRESS_WIDTH -- rd
        )-1
        downto 0
    );
    signal exmemInBv, exmemOutBv: bit_vector(
        (
            WB_CONTROL_WIDTH
            + M_CONTROL_WIDTH
            + 1 -- aluZero
            + 2*DATA_WORD_SIZE -- aluResult, q2
            + REGISTER_ADDRESS_WIDTH -- rd
        )-1
        downto 0
    );
    signal memwbInBv, memwbOutBv: bit_vector(
        (
            WB_CONTROL_WIDTH
            + 2*DATA_WORD_SIZE -- aluResult, dmOut
            + REGISTER_ADDRESS_WIDTH -- rd
        )-1
        downto 0
    );

begin

    pcIn <=
        pcPlusShift when pcSrc = '1' else
        pcPlusFour;

    pc: reg
        generic map(WORD_SIZE)
        port map(
            clock, reset, '1', pcWrite,
            pcIn, pcOut
        );

    fourAdder: alu
        generic map(WORD_SIZE)
        port map(
            pcOut, (2 => '1', others => '0'),
            pcPlusFour,
            "0010",
            open, open, open
        );

    imAddr <= pcOut;


    -- TODO Consider using others => '0' instead of NOP
    ifidIn <= imOut when ifidFlush = '1' else NOP;
    ifidReg: pipeline_reg
        generic map(INSTRUCTION_SIZE)
        port map(
            clock, reset,
            ifidIn, ifidOut
        );


    opcode <= ifidOut(6 downto 0);
    rd <= ifidOut(11 downto 7);
    funct3 <= ifidOut(14 downto 12);
    rr1 <= ifidOut(19 downto 15);
    rr2 <= ifidOut(24 downto 20);
    -- TODO Decode func7 (31 downto 25)


    registers: regfile
        generic map(NUMBER_OF_REGISTERS, WORD_SIZE)
        port map(
            clock, reset, regWrite,
            rr1, rr2, wr,
            d,
            q1, q2
        );


    -- TODO Add MUXes to comparator input
    -- for data forwarding
    comparator: alu
        generic map(WORD_SIZE)
        port map(
            q1, q2, open,
            "0110",
            registersEqual, open, open
        );


    extend: signExtend
        port map(
            ifidOut,
            signExtendOut
        );


    shift2: Shiftleft2
        port map(signExtendOut, shiftOut);


    shiftAdder: alu
        generic map(WORD_SIZE)
        port map(
            pcOut, shiftOut,
            pcPlusShift,
            "0010",
            open, open, open
        );


    idexInBv <=
        "00" -- WB
        & "000" -- M
        & "000" -- EX
        & q1
        & q2
        & signExtendOut
        & wr;
    idexOutBv <=
        idexOut.wb
        & idexOut.m
        & idexOut.ex
        & idexOut.q1
        & idexOut.q2
        & idexOut.immExtended
        & idexOut.rd;

    idexReg: pipeline_reg
        generic map(idexInBv'length)
        port map(
            clock, reset,
            idexInBv,
            idexOutBv
        );


    dataAluA <= idexOut.q1;
    dataAluB <=
        idexOut.immExtended when aluSrc = '1' else
        idexOut.q2;

    dataAlu: alu
        generic map(WORD_SIZE)
        port map(
            dataAluA, dataAluB,
            dataAluResult,
            aluCtrl,
            aluZero, dataOverflow, dataCarryOut
        );
    zero <= aluZero;


    exmemInBv <=
        idexOut.wb
        & idexOut.m
        & aluZero
        & dataAluResult
        & idexOut.q2
        & idexOut.rd;
    exmemOutBv <=
        exmemOut.wb
        & exmemOut.m
        & exmemOut.aluZero
        & exmemOut.aluResult
        & exmemOut.q2
        & exmemOut.rd;

    exmemReg: pipeline_reg
        generic map(exmemInBv'length)
        port map(
            clock, reset,
            exmemInBv,
            exmemOutBv
        );


    dmAddr <= exmemOut.aluResult;
    dmIn <= exmemOut.q2;


    memwbInBv <=
        exmemOut.wb
        & dmOut
        & exmemOut.aluResult
        & exmemOut.rd;
    memwbOutBv <=
        memwbOut.wb
        & memwbOut.dmOut
        & memwbOut.aluResult
        & memwbOut.rd;

    memwbReg: pipeline_reg
        generic map(memwbInBv'length)
        port map(
            clock, reset,
            memwbInBv,
            memwbOutBv
        );


    d <= dmOut when memToReg = '1' else dataAluResult;

    wr <= memwbOut.rd;

end architecture arch;
