library ieee;
use ieee.numeric_bit.rising_edge;

entity ff is
    port(
        clock, reset, enable, wr: in bit;
        dataIn: in bit;
        dataOut: out bit
    );
end entity;
architecture functional of ff is
    signal internalData: bit;
begin
    dataOut <= internalData;
    update: process(clock, reset)
    begin
        if reset = '1' then
            internalData <= '0';
        elsif wr = '1' and enable = '1'
                and rising_edge(clock) then
            internalData <= dataIn;
        end if;
    end process;
end architecture;
