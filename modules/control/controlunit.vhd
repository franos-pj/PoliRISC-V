entity controlunit is
    port(
        --- From Datapath ---
        opcode   : in  bit_vector (6 downto 0);
        --- To   Datapath ---
        -- EX stage
        aluSrc   : out bit;
        aluOp    : out bit_vector (1 downto 0);
        -- MEM stage
        branch   : out bit;
        memRead  : out bit;
        memWrite : out bit;
        -- WB stage
        memToReg : out bit;
        regWrite : out bit
    );
end entity;

architecture arch_controlunit of controlunit is

begin

    regWrite <= opcode(4) or not opcode(5);
    aluSrc   <= (not opcode(6)) and (not opcode(4));
    aluOp    <= opcode(4) & opcode(6);
    branch   <= opcode(6);
    memRead  <= not opcode(5);
    memWrite <= (not opcode(6)) and opcode(5) and (not opcode(4));
    memToReg <= (not opcode(5)) and (not opcode(4));

end architecture;