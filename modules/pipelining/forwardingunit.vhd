library ieee;
use ieee.numeric_bit.all;

entity forwardingunit is
    port(
        exmem_regWrite, memwb_regWrite : in  bit;
        idex_Rs1, idex_Rs2             : in  bit_vector (4 downto 0);
        exmem_Rd, memwb_Rd             : in  bit_vector (4 downto 0);
        forwardA, forwardB             : out bit_vector (1 downto 0)
    );
end entity;

architecture behavioural of forwardingunit is
begin

    -- process for forwardA
    process(idex_Rs1, exmem_Rd, memwb_Rd, exmem_regWrite, memwb_regWrite)
    begin

        if ((exmem_regWrite = '1')
            and (to_integer(unsigned(exmem_Rd)) /= 0)
            and (exmem_Rd = idex_Rs1)) then
            
            forwardA <= "10";
        
        elsif ((memwb_regWrite = '1')
               and (to_integer(unsigned(memwb_Rd)) /= 0)
               and (memwb_Rd = idex_Rs1)) then

            forwardA <= "01";

        else forwardA <= "00";
        end if;

    end process;


    -- process for forwardB
    process(idex_Rs2, exmem_Rd, memwb_Rd, exmem_regWrite, memwb_regWrite)
    begin

        if ((exmem_regWrite = '1')
            and (to_integer(unsigned(exmem_Rd)) /= 0)
            and (exmem_Rd = idex_Rs2)) then
            
            forwardB <= "10";
        
        elsif ((memwb_regWrite = '1')
               and (to_integer(unsigned(memwb_Rd)) /= 0)
               and (memwb_Rd = idex_Rs2)) then

            forwardB <= "01";

        else forwardB <= "00";
        end if;

    end process;

end architecture;
