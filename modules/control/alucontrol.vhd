entity alucontrol is
    port(
        funct3   : in  bit_vector (2 downto 0);
        funct7_5 : in  bit;
        aluOp    : in  bit_vector (1 downto 0);
        aluCtrl  : out bit_vector (3 downto 0)
    );
end entity;

architecture arch_alucontrol of alucontrol is

begin

    aluCtrl <= "0010" when aluOp = "00" or (aluOp = "10" and funct3 = "000" and funct7_5 = '0') else
               "0110" when aluOp = "01" or (aluOp = "10" and funct3 = "000" and funct7_5 = '1') else
               "0000" when aluOp = "10" and funct3 = "111" and funct7_5 = '0' else
               "0001" when aluOp = "10" and funct3 = "110" and funct7_5 = '0' else
               "1111";

end architecture;