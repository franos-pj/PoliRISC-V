library ieee;
use ieee.std_logic_1164.all;

entity hdu_data_tb is
end entity;

architecture tb of hdu_data_tb is
  
component hdu_data is
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
end component;

signal id_ex_memread_in: std_logic;
signal id_ext_register_rd_in: std_logic_vector(4 downto 0);
signal if_id_register_rs1_in: std_logic_vector(4 downto 0);
signal if_id_register_rs2_in: std_logic_vector(4 downto 0);

signal pc_write_out, if_id_write_out, pass_bubble_out: std_logic;

begin
    dut: hdu_data port map(
        id_ex_memread_in,
        id_ext_register_rd_in,
        if_id_register_rs1_in,
        if_id_register_rs2_in,
        pc_write_out,
        if_id_write_out,
        pass_bubble_out
    );

    stimulus: process is
    begin
  
    assert false report "Inicio das simulacoes" severity note;
    
    id_ex_memread_in <= '0';
    id_ext_register_rd_in  <= "10000";
    if_id_register_rs1_in  <= "10000";
    if_id_register_rs2_in  <= "10000";
    wait for 100 us;
    assert pc_write_out='1' and if_id_write_out='1' and pass_bubble_out='0' report "Erro no caso 1" severity note;

    id_ex_memread_in <= '1';
    id_ext_register_rd_in  <= "00100";
    if_id_register_rs1_in  <= "00100";
    if_id_register_rs2_in  <= "00000";
    wait for 100 us;
    assert pc_write_out='0' and if_id_write_out='0' and pass_bubble_out='1' report "Erro no caso 2" severity note;

    id_ex_memread_in <= '1';
    id_ext_register_rd_in  <= "00100";
    if_id_register_rs1_in  <= "00000";
    if_id_register_rs2_in  <= "00100";
    wait for 100 us;
    assert pc_write_out='0' and if_id_write_out='0' and pass_bubble_out='1' report "Erro no caso 3" severity note;

    id_ex_memread_in <= '1';
    id_ext_register_rd_in  <= "10000";
    if_id_register_rs1_in  <= "00100";
    if_id_register_rs2_in  <= "00100";
    wait for 100 us;
    assert pc_write_out='1' and if_id_write_out='1' and pass_bubble_out='0' report "Erro no caso 4" severity note;

    assert false report "Fim das simulacoes" severity note;
    
    wait;
  end process;

end architecture;
