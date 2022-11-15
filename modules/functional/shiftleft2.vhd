entity Shiftleft2 is
    generic (
        inputSize: natural := 64;
        outputSize: natural := 64
    );
    port(
        i: in bit_vector(inputSize-1 downto 0);
        o: out bit_vector(outputSize-1 downto 0)
    );
end entity Shiftleft2;
architecture arch of Shiftleft2 is
begin
    o <= i(outputSize-3 downto 0) & "00";
end architecture arch;
