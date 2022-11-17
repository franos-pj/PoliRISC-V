library ieee;
use ieee.numeric_bit.all;

entity forwardingunit is
    port(
        idex_Rs1, idex_Rs2: in bit_vector(63 downto 0);
        exmem_Rd, memwb_Rd: in bit_vector(63 downto 0);
        exmem_regwrite, memwb_regwrite: in bit;
        
        ForwardA, ForwardB: out bit_vector(1 downto 0);
    );
end entity;

architecture behavioural of forwardingunit is
begin

    -- process for ForwardA
    process(idex_Rs1, exmem_Rd, memwb_Rd, exmem_regwrite, memwb_regwrite)
    begin

        if ((exmem_regwrite = '1')
            and (to_integer(unsigned(exmem_Rd)) /= 0)
            and (exmem_Rd = idex_Rs1)) then
            
            ForwardA <= "10";
        
        elsif ((memwb_regwrite = '1')
               and (to_integer(unsigned(memwb_Rd)) /= 0)
               and (memwb_Rd = idex_Rs1)) then

            ForwardA <= "01";

        else ForwardA <= "00";
        end if;

    end process;


    -- process for ForwardB
    process(idex_Rs2, exmem_Rd, memwb_Rd, exmem_regwrite, memwb_regwrite)
    begin

        if ((exmem_regwrite = '1')
            and (to_integer(unsigned(exmem_Rd)) /= 0)
            and (exmem_Rd = idex_Rs2)) then
            
            ForwardB <= "10";
        
        elsif ((memwb_regwrite = '1')
               and (to_integer(unsigned(memwb_Rd)) /= 0)
               and (memwb_Rd = idex_Rs2)) then

            ForwardB <= "01";

        else ForwardB <= "00";
        end if;

    end process;

end architecture;
