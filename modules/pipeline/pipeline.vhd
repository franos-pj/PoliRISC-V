use work.parameters.DATA_WORD_SIZE;
use work.parameters.INSTRUCTION_WORD_SIZE;
use work.parameters.REGISTER_ADDRESS_WIDTH;

package pipeline is
    constant WB_CONTROL_WIDTH: natural := 2;
    constant M_CONTROL_WIDTH: natural := 3;
    constant EX_CONTROL_WIDTH: natural := 7;


    type ifid_t is record
        instruction: bit_vector(INSTRUCTION_WORD_SIZE-1 downto 0);
        pc: bit_vector(DATA_WORD_SIZE-1 downto 0);
    end record;
    type idex_t is record
        -- WB --
        memToReg,
        regWrite: bit;
        ----
        -- MEM --
        branch,
        memRead,
        memWrite: bit;
        ----
        -- EX --
        funct3: bit_vector(2 downto 0);
        funct7_5,
        aluSrc: bit;
        aluOp: bit_vector(1 downto 0);
        ----
        q1,
        q2,
        immExtended,
        pc: bit_vector(DATA_WORD_SIZE-1 downto 0);
        rs1, rs2, rd: bit_vector(REGISTER_ADDRESS_WIDTH-1 downto 0);
    end record;
    type exmem_t is record
        -- WB --
        memToReg,
        regWrite: bit;
        ----
        -- MEM --
        branch,
        memRead,
        memWrite: bit;
        ----
        aluZero: bit;
        aluResult,
        q2,
        immExtended,
        pc: bit_vector(DATA_WORD_SIZE-1 downto 0);
        rd: bit_vector(REGISTER_ADDRESS_WIDTH-1 downto 0);
    end record;
    type memwb_t is record
        -- WB --
        memToReg,
        regWrite: bit;
        ----
        dmOut,
        aluResult: bit_vector(DATA_WORD_SIZE-1 downto 0);
        rd: bit_vector(REGISTER_ADDRESS_WIDTH-1 downto 0);
    end record;
end package pipeline;
