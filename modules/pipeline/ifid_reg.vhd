use work.parameters.DATA_WORD_SIZE;
use work.parameters.INSTRUCTION_WORD_SIZE;

entity ifid_reg is
    port(
        clock, reset: in bit;
        -- Input
        in_instruction: in bit_vector(INSTRUCTION_WORD_SIZE-1 downto 0);
        in_pc: in bit_vector(DATA_WORD_SIZE-1 downto 0);
        -- Output
        out_instruction: out bit_vector(INSTRUCTION_WORD_SIZE-1 downto 0);
        out_pc: out bit_vector(DATA_WORD_SIZE-1 downto 0)
    );
end entity;

architecture arch of ifid_reg is
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
    instruction_reg: reg
        generic map(INSTRUCTION_WORD_SIZE)
        port map(
            clock, reset, '1', '1',
            in_instruction, out_instruction
        );

    pc_reg: reg
        generic map(DATA_WORD_SIZE)
        port map(
            clock, reset, '1', '1',
            in_pc, out_pc
        );
end arch;
