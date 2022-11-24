entity polilegsc is
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
end entity;

architecture arch of polilegsc is

    component controlunit is
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
    end component;

    component alucontrol is
        port(
            funct3   : in  bit_vector (2 downto 0);
            funct7_5 : in  bit;
            aluOp    : in  bit_vector (1 downto 0);
            aluCtrl  : out bit_vector (3 downto 0)
        );
    end component;

    component forwarding is
        port(
            exmem_regWrite, memwb_regWrite : in  bit;
            idex_Rs1, idex_Rs2             : in  bit_vector (4 downto 0);
            exmem_Rd, memwb_Rd             : in  bit_vector (4 downto 0);
            forwardA, forwardB             : out bit_vector (1 downto 0)
        );
    end component;

    component data_hazard is
        port(
            -- Identifica load
            id_ex_memread: in bit;
            id_ex_register_rd: in bit_vector(4 downto 0);
            -- Identifica se usa saida do load
            if_id_register_rs1: in bit_vector(4 downto 0);
            if_id_register_rs2: in bit_vector(4 downto 0);

            -- Desativam os componentes quando ocorre stall
            pc_write: out bit;
            if_id_write: out bit;
            -- Aciona MUX para passar vetor de 0 nos sinais de controle
            pass_bubble: out bit
        );
    end component;

    component control_hazard is
        port (
            branch: in bit;
            zero: in bit;
            ifidFlush: out bit;
            idexFlush: out bit
        );
    end component;

    component datapath is
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
    end component;

    -- controlunit
    --- From Datapath ---
    signal opcode   : bit_vector (6 downto 0);
    --- To   Datapath ---
    -- EX stage
    signal aluSrc   :bit;
    -- MEM stage
    signal branch   :bit;
    signal memRead  :bit;
    signal memWrite :bit;
    -- WB stage
    signal memToReg :bit;
    signal regWrite :bit;

    -- alucontrol
    signal funct3   : bit_vector (2 downto 0);
    signal funct7_5 : bit;
    signal aluCtrl  : bit_vector (3 downto 0);

    -- forwarding
    signal exmem_regWrite, memwb_regWrite : bit;
    signal idex_Rs1, idex_Rs2             : bit_vector (4 downto 0);
    signal exmem_Rd, memwb_Rd             : bit_vector (4 downto 0);
    signal forwardA, forwardB             : bit_vector (1 downto 0);

    -- data_hazard
    -- Identifica load
    signal id_ex_memread:     bit;
    signal id_ex_register_rd: bit_vector(4 downto 0);
    -- Identifica se usa saida do load
    signal if_id_register_rs1: bit_vector(4 downto 0);
    signal if_id_register_rs2: bit_vector(4 downto 0);

    -- Desativam os componentes quando ocorre stall
    signal pc_write:    bit;
    signal if_id_write: bit;
    -- Aciona MUX para passar vetor de 0 nos sinais de controle
    signal pass_bubble: bit;


    -- control_hazard
    signal hazardBranch: bit;
    signal hazardZero: bit;
    signal ifidFlush: bit;
    signal idexFlush: bit;

    -- datapath
    -- IM interface
    signal imAddr:bit_vector(63 downto 0);
    signal imOut:bit_vector(31 downto 0);
    -- DM interface
    signal
        dmAddr,
        dmIn:  bit_vector(63 downto 0);
    signal dmOut: bit_vector(63 downto 0);

    -- Pipeline control signals
    signal aluOpIn: bit_vector(1 downto 0);
    signal aluOpOut: bit_vector(1 downto 0);

begin

    dmem_we <= memWrite and (not memRead);

    cu: controlunit port map(
        opcode   => opcode,
        --- To   Datapath ---
        -- EX stage
        aluSrc   => aluSrc,
        aluOp    => aluOpIn,
        -- MEM stage
        branch   => branch,
        memRead  => memRead,
        memWrite => memWrite,
        -- WB stage
        memToReg => memToReg,
        regWrite => regWrite
    );

    aluCu: alucontrol port map(
        funct3   => funct3,
        funct7_5 => funct7_5,
        aluOp    => aluOpOut,
        aluCtrl  => aluCtrl
    );

    fw: forwarding port map (
        exmem_regWrite => exmem_regWrite,
        memwb_regWrite => memwb_regWrite,
        idex_Rs1       => idex_Rs1,
        idex_Rs2       => idex_Rs2,
        exmem_Rd       => exmem_Rd,
        memwb_Rd       => memwb_Rd,
        forwardA       => forwardA,
        forwardB       => forwardB
    );

    ch: control_hazard port map (
        branch      => hazardBranch,
        zero        => hazardZero,
        ifidFlush   => ifidFlush,
        idexFlush   => idexFlush
    );

    dh: data_hazard port map(
        -- Identifica load
        id_ex_memread      => id_ex_memread,
        id_ex_register_rd  => id_ex_register_rd,
        -- Identifica se usa saida do load
        if_id_register_rs1 => if_id_register_rs1,
        if_id_register_rs2 => if_id_register_rs2,
        -- Desativam os componentes quando ocorre stall
        pc_write           => pc_write,
        if_id_write        => if_id_write,
        -- Aciona MUX para passar vetor de 0 nos sinais de controle
        pass_bubble        => pass_bubble
    );

    dp: datapath port map(
        -- Common
        clock               => clock,
        reset               => reset,
        -- From Control Unit
        branch              => branch,
        memRead             => memRead,
        memWrite            => memWrite,
        memToReg            => memToReg,
        aluCtrl             => aluCtrl,
        aluSrc              => aluSrc,
        regWrite            => regWrite,
        -- To Control Unit
        opcode              => opcode,
        funct3              => funct3,
        funct7_5            => funct7_5,
        -- IM interface
        imAddr              => imAddr,
        imOut               => imOut,
        -- DM interface
        dmAddr              => dmAddr,
        dmIn                => dmIn,
        dmOut               => dmOut,

        -- Pipeline control signals
        aluOpIn            => aluOpIn,
        aluOpOut           => aluOpOut,
        --- Hazard detection unit
        ---- Data hazard
        ----- Identifica load
        id_ex_memread      => id_ex_memread,
        id_ex_register_rd  => id_ex_register_rd,
        ----- Identifica se usa saida do load
        if_id_register_rs1 => if_id_register_rs1,
        if_id_register_rs2 => if_id_register_rs2,
        ----- Desativam os componentes quando ocorre stall
        pc_write           => pc_write,
        if_id_write        => if_id_write,
        ----- Aciona MUX para passar vetor de 0 nos sinais de controle
        pass_bubble        => pass_bubble,
        ---- Control hazard
        hazardBranch       => hazardBranch,
        hazardZero         => hazardZero,
        ifidFlush          => ifidFlush,
        idexFlush          => idexFlush,
        --- Forwarding
        exmem_regWrite     => exmem_regWrite,
        memwb_regWrite     => memwb_regWrite,
        idex_Rs1           => idex_Rs1,
        idex_Rs2           => idex_Rs2,
        exmem_Rd           => exmem_Rd,
        memwb_Rd           => memwb_Rd,
        forwardA           => forwardA,
        forwardB           => forwardB
    );

end architecture arch;
