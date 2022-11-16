use work.parameters.DATA_WORD_SIZE;
use work.parameters.INSTRUCTION_WORD_SIZE;
use work.parameters.REGISTER_ADDRESS_WIDTH;

package pipeline is
    constant WB_CONTROL_WIDTH: natural := 2;
    constant M_CONTROL_WIDTH: natural := 3;
    constant EX_CONTROL_WIDTH: natural := 3;

    subtype wb_t is bit_vector(WB_CONTROL_WIDTH-1 downto 0);
    subtype m_t is bit_vector(M_CONTROL_WIDTH-1 downto 0);
    subtype ex_t is bit_vector(EX_CONTROL_WIDTH-1 downto 0);

    subtype ifid_t is bit_vector(INSTRUCTION_WORD_SIZE-1 downto 0);
    type idex_t is record
        wb: wb_t;
        m: m_t;
        ex: ex_t;
        q1,
        q2,
        immExtended: bit_vector(DATA_WORD_SIZE-1 downto 0);
        rd: bit_vector(REGISTER_ADDRESS_WIDTH-1 downto 0);
    end record;
    type exmem_t is record
        wb: wb_t;
        m: m_t;
        aluZero: bit;
        aluResult,
        q2: bit_vector(DATA_WORD_SIZE-1 downto 0);
        rd: bit_vector(REGISTER_ADDRESS_WIDTH-1 downto 0);
    end record;
    type memwb_t is record
        wb: wb_t;
        dmOut: bit_vector(DATA_WORD_SIZE-1 downto 0);
        aluResult,
        rd: bit_vector(REGISTER_ADDRESS_WIDTH-1 downto 0);
    end record;
end package pipeline;
