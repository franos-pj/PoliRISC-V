library ieee;
use ieee.math_real.ceil;
use ieee.math_real.log2;

package parameters is
    constant MEM_WIDTH: natural := 11;
    constant DATA_WORD_SIZE: natural := 64; -- bits
    constant INSTRUCTION_WORD_SIZE: natural := 32; -- bits
    constant MEMORY_WORD_SIZE: natural := 8; -- bits
    constant NUMBER_OF_REGISTERS: natural := 32;
    constant REGISTER_ADDRESS_WIDTH: natural :=
        natural(ceil(log2(real(NUMBER_OF_REGISTERS))));

    constant DAT_BASE_PATH: string := "../software/";
    constant FOLDER: string := "fibonacci/";
    constant RAM_DAT_FILE: string := DAT_BASE_PATH & FOLDER &
        "ram.dat";
    constant ROM_DAT_FILE: string := DAT_BASE_PATH & FOLDER &
        "rom.dat";
end package parameters;
