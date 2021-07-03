entity toplevel is
    port(
        clock, reset: in bit
    );
end entity;
architecture arch of toplevel is

    component polilegsc is
        port(
            clock, reset: in bit;
            -- Data Memory
            dmem_addr,
            dmem_dati: out bit_vector(63 downto 0);
            dmem_dato: in bit_vector(63 downto 0);
            dmem_we: out bit;
            -- Instruction memory
            imem_addr: out bit_vector(63 downto 0);
            imem_data: in bit_vector(31 downto 0)
        );
    end component;

    component ram is
        generic(
            mem_width_in_bits: natural := 64;
            word_size: natural := 64;
            mem_word_size: natural := 8;
            init_file: string := "../software/ram.dat"
        );
        port(
            ck, wr : in  bit;
            addr   : in  bit_vector(mem_width_in_bits-1 downto 0);
            data_i : in  bit_vector(word_size-1 downto 0);
            data_o : out bit_vector(word_size-1 downto 0)
        );
    end component;

    component rom is
        generic(
            mem_width_in_bits: natural := 64;
            word_size: natural := 32;
            mem_word_size: natural := 8;
            init_file: string := "../software/rom.dat"
        );
        port(
            addr   : in  bit_vector(mem_width_in_bits-1 downto 0);
            data_o : out bit_vector(word_size-1 downto 0)
        );
    end component;

    constant MEM_WIDTH: natural := 64;
    constant DATA_WORD_SIZE: natural := 64;
    constant INSTRUCTION_WORD_SIZE: natural := 32;
    constant MEMORY_WORD_SIZE: natural := 8;
    constant RAM_DAT_FILE: string := "../software/ram.dat";
    constant ROM_DAT_FILE: string := "../software/rom.dat";

    -- Data Memory
    signal dmem_addr, dmem_dati: bit_vector(63 downto 0);
    signal dmem_dato: bit_vector(63 downto 0);
    signal dmem_we: bit;
    -- Instruction memory
    signal imem_addr: bit_vector(63 downto 0);
    signal imem_data: bit_vector(31 downto 0);

begin

    processor: polilegsc port map(
        clock, reset,
        dmem_addr,
        dmem_dati,
        dmem_dato,
        dmem_we,
        imem_addr,
        imem_data
    );

    -- TODO instantiate smaller memory for testing
    dataMemory: ram
        generic map(
            MEM_WIDTH,
            DATA_WORD_SIZE,
            MEMORY_WORD_SIZE,
            RAM_DAT_FILE
        )
        port map(
            clock,
            dmem_we,
            dmem_addr,
            dmem_dati,
            dmem_dato
        );
    
    -- TODO instantiate smaller memory for testing
    instructionMemory: rom
        generic map(
            MEM_WIDTH,
            INSTRUCTION_WORD_SIZE,
            MEMORY_WORD_SIZE,
            ROM_DAT_FILE
        )
        port map(
            imem_addr,
            imem_data
        );

end architecture arch;
