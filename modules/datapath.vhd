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
        branch,
        memRead,
        memWrite: in bit;
        memToReg: in bit;
        aluCtrl: in bit_vector(3 downto 0);
        aluSrc,
        regWrite: in bit;
        -- To Control Unit
        opcode: out bit_vector(6 downto 0);
        funct3: out bit_vector(2 downto 0);
        funct7_5: out bit;
        -- IM interface
        imAddr: out bit_vector(63 downto 0);
        imOut: in bit_vector(31 downto 0);
        -- DM interface
        dmAddr,
        dmIn: out bit_vector(63 downto 0);
        dmOut: in bit_vector(63 downto 0);

        -- Pipeline control signals
        aluOpIn: in bit_vector(1 downto 0);
        aluOpOut: out bit_vector(1 downto 0);
        exmem_memWrite, exmem_memRead: out bit;
        --- Hazard detection unit
        ---- Data hazard
        ----- Identifica load
        id_ex_memread: out bit;
        id_ex_register_rd: out bit_vector(4 downto 0);
        ----- Identifica se usa saida do load
        if_id_register_rs1: out bit_vector(4 downto 0);
        if_id_register_rs2: out bit_vector(4 downto 0);
        ----- Desativam os componentes quando ocorre stall
        pc_write: in bit;
        if_id_write: in bit;
        ----- Aciona MUX para passar vetor de 0 nos sinais de controle
        pass_bubble: in bit;
        ---- Control hazard
        hazardBranch: out bit;
        hazardZero: out bit;
        ifidFlush: in bit;
        idexFlush: in bit;
        --- Forwarding
        exmem_regWrite, memwb_regWrite: out  bit;
        idex_Rs1, idex_Rs2: out  bit_vector (4 downto 0);
        exmem_Rd, memwb_Rd: out  bit_vector (4 downto 0);
        forwardA, forwardB: in bit_vector (1 downto 0)
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

    signal rs1, rs2, rd: bit_vector(REGISTER_ADDR_SIZE-1 downto 0);
    signal q1, q2, d: bit_vector(WORD_SIZE-1 downto 0);

    signal dataAluA, dataAluB, dataAluResult: bit_vector(WORD_SIZE-1 downto 0);
    signal dataOverflow, dataCarryOut: bit;

    signal signExtendOut: bit_vector(WORD_SIZE-1 downto 0);

    signal pcPlusFour: bit_vector(WORD_SIZE-1 downto 0);

    signal shiftOut: bit_vector(WORD_SIZE-1 downto 0);

    signal pcPlusShift: bit_vector(WORD_SIZE-1 downto 0);

    signal pcIn, pcOut: bit_vector(WORD_SIZE-1 downto 0);


    component ifid_reg is
        generic(
            wordSize: natural := 64
        );
        port(
            clock, reset: in bit;
            dataIn: in bit_vector(wordSize-1 downto 0);
            dataOut: out bit_vector(wordSize-1 downto 0)
        );
    end component;

    component idex_reg is
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
    end component;

    component exmem_reg is
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
    end component;

    component memwb_reg is
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
    end component;

    constant NOP: bit_vector(31 downto 0) := x"00000013";

    signal aluZero: bit;

    signal ifidIn, ifidOut: ifid_t;
    signal ifid_funct3: bit_vector(2 downto 0);
    signal ifid_funct7_5: bit;
    signal pcSrc: bit;
    signal idexReset: bit; -- Insert bubble due to data hazard
    signal pcWrite: bit;

    signal
        idexIn_memToReg,
        idexIn_regWrite,
        idexIn_branch,
        idexIn_memRead,
        idexIn_memWrite,
        idexIn_funct7_5,
        idexIn_aluSrc: bit;
    signal idexIn_funct3: bit_vector(2 downto 0);
    signal idexIn_aluOpIn: bit_vector(1 downto 0);

    signal idexOut: idex_t;
    signal exmemOut: exmem_t;
    signal memwbOut: memwb_t;

    signal pcClock, regfileClock: bit;

begin

    pcIn <=
        pcPlusShift when pcSrc = '1' else
        pcPlusFour;

    pcWrite <= pc_write;

    pcClock <= not clock;
    pc: reg
        generic map(WORD_SIZE)
        port map(
            pcClock, reset, '1', pcWrite,
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


    ifidIn <= imOut when ifidFlush = '1' else NOP;

    -- To Hazard Detection unit
    id_ex_memread <= idexOut.memRead;
    id_ex_register_rd <= idexOut.rd;
    if_id_register_rs1 <= rs1;
    if_id_register_rs2 <= rs2;


    ifidReg: ifid_reg
        generic map(INSTRUCTION_SIZE)
        port map(
            clock, reset,
            ifidIn, ifidOut
        );


    opcode <= ifidOut(6 downto 0);
    rd <= ifidOut(11 downto 7);
    ifid_funct3 <= ifidOut(14 downto 12);
    rs1 <= ifidOut(19 downto 15);
    rs2 <= ifidOut(24 downto 20);
    ifid_funct7_5 <= ifidOut(30);


    regfileClock <= not clock;
    registers: regfile
        generic map(NUMBER_OF_REGISTERS, WORD_SIZE)
        port map(
            regfileClock, reset, memwbOut.regWrite,
            rs1, rs2, memwbOut.rd,
            d,
            q1, q2
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


    idexIn_memToReg <= '0'   when pass_bubble = '1' or idexFlush = '1' else memToReg;
    idexIn_regWrite <= '0'   when pass_bubble = '1' or idexFlush = '1' else regWrite;
    idexIn_branch   <= '0'   when pass_bubble = '1' or idexFlush = '1' else branch;
    idexIn_memRead  <= '0'   when pass_bubble = '1' or idexFlush = '1' else memRead;
    idexIn_memWrite <= '0'   when pass_bubble = '1' or idexFlush = '1' else memWrite;
    idexIn_funct3   <= "000" when pass_bubble = '1' or idexFlush = '1' else ifid_funct3;
    idexIn_funct7_5 <= '0'   when pass_bubble = '1' or idexFlush = '1' else ifid_funct7_5;
    idexIn_aluSrc   <= '0'   when pass_bubble = '1' or idexFlush = '1' else aluSrc;
    idexIn_aluOpIn  <= "00"  when pass_bubble = '1' or idexFlush = '1' else aluOpIn;

    idex: idex_reg port map (
        clock, reset,
        -- INPUT
        idexIn_memToReg,
        idexIn_regWrite,
        idexIn_branch,
        idexIn_memRead,
        idexIn_memWrite,
        idexIn_funct3,
        idexIn_funct7_5,
        idexIn_aluSrc,
        idexIn_aluOpIn,
        q1,
        q2,
        signExtendOut,
        rs1,
        rs2,
        rd,
        -- OUTPUT
        -- WB --
        idexOut.memToReg,
        idexOut.regWrite,
        ----
        -- MEM --
        idexOut.branch,
        idexOut.memRead,
        idexOut.memWrite,
        ----
        idexOut.funct3,
        idexOut.funct7_5,
        idexOut.aluSrc,
        idexOut.aluOp,
        idexOut.q1,
        idexOut.q2,
        idexOut.immExtended,
        idexOut.rs1,
        idexOut.rs2,
        idexOut.rd

    );


    aluOpOut <= idexOut.aluOp;


    -- To Forwarding Unit
    exmem_regWrite <= exmemOut.regWrite;
    memwb_regWrite <= memwbOut.regWrite;
    idex_Rs1 <=  idexOut.rs1;
    idex_Rs2 <= idexOut.rs2;
    exmem_Rd <= exmemOut.rd;
    memwb_Rd <= memwbOut.rd;


    dataAluA <=
        exmemOut.aluResult when forwardA = "10" else
        memwbOut.dmOut when forwardA = "01" else
        idexOut.q1;
    dataAluB <=
        exmemOut.aluResult when forwardB = "10" else
        memwbOut.dmOut when forwardB = "01" else
        idexOut.immExtended when forwardB = "00" and idexOut.aluSrc = '1' else
        idexOut.q2;


    dataAlu: alu
        generic map(WORD_SIZE)
        port map(
            dataAluA, dataAluB,
            dataAluResult,
            aluCtrl,
            aluZero, dataOverflow, dataCarryOut
        );


    hazardBranch <= exmemOut.branch;
    hazardZero <= exmemOut.aluZero;


    exmem: exmem_reg port map (
        clock, reset,
        -- INPUT
        -- WB --
        idexOut.memToReg,
        idexOut.regWrite,
        ----
        -- MEM --
        idexOut.branch,
        idexOut.memRead,
        idexOut.memWrite,
        ----
        aluZero,
        dataAluResult,
        idexOut.q2,
        idexOut.rd,
        -- OUTPUT
        -- WB --
        exmemOut.memToReg,
        exmemOut.regWrite,
        ----
        -- MEM --
        exmemOut.branch,
        exmemOut.memRead,
        exmemOut.memWrite,
        ----
        exmemOut.aluZero,
        exmemOut.aluResult,
        exmemOut.q2,
        exmemOut.rd
    );


    dmAddr <= exmemOut.aluResult;
    dmIn <= exmemOut.q2;
    pcSrc <= exmemOut.aluZero and exmemOut.branch;
    exmem_memRead <= exmemOut.memRead;
    exmem_memWrite <= exmemOut.memWrite;


    memwb: memwb_reg port map (
        clock, reset,
        -- INPUT
        -- WB --
        exmemOut.memToReg,
        exmemOut.regWrite,
        ----
        dmOut,
        exmemOut.aluResult,
        exmemOut.rd,
        -- OUTPUT
        -- WB --
        memwbOut.memToReg,
        memwbOut.regWrite,
        ----
        memwbOut.dmOut,
        memwbOut.aluResult,
        memwbOut.rd
    );

    d <= memwbOut.dmOut when memwbOut.memToReg = '1' else memwbOut.aluResult;

end architecture arch;
