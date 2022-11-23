entity data_hazard is
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
end data_hazard;

architecture arch of data_hazard is
    signal stall: bit;
    signal rs1_eq_rd: bit;
    signal rs2_eq_rd: bit;
begin
    rs1_eq_rd <= '1' when (if_id_register_rs1 = id_ex_register_rd) else '0';
    rs2_eq_rd <= '1' when (if_id_register_rs2 = id_ex_register_rd) else '0';
    stall <= (id_ex_memread and(rs1_eq_rd or rs2_eq_rd));

    pc_write <= not(stall);
    if_id_write <= not(stall);
    pass_bubble <= stall;
end architecture;
