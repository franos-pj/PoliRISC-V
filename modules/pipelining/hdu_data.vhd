library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hdu_data is
    port(
        -- Identifica load
        id_ex_memread: in std_logic;
        id_ex_register_rd: in std_logic_vector(4 downto 0);
        -- Identifica se usa saida do load
        if_id_register_rs1: in std_logic_vector(4 downto 0);
        if_id_register_rs2: in std_logic_vector(4 downto 0);

        -- Desativam os componentes quando ocorre stall
        pc_write: out std_logic;
        if_id_write: out std_logic;
        -- Aciona MUX para passar vetor de 0 nos sinais de controle
        pass_bubble: out std_logic
    );
end hdu_data;

architecture behav of hdu_data is
    signal stall: std_logic;
    signal rs1_eq_rd: std_logic;
    signal rs2_eq_rd: std_logic;
begin
    rs1_eq_rd <= '1' when (if_id_register_rs1 = id_ex_register_rd) else '0';
    rs2_eq_rd <= '1' when (if_id_register_rs2 = id_ex_register_rd) else '0';
    stall <= (id_ex_memread and(rs1_eq_rd or rs2_eq_rd));

    pc_write <= not(stall);
    if_id_write <= not(stall);
    pass_bubble <= stall;
end architecture;