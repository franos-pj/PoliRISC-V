entity control_hazard is
    port (
        branch: in bit;
        zero: in bit;
        idexFlush: out bit;
        exmemFlush: out bit
    );
end entity;

architecture arch of control_hazard is
    signal flush: bit;
begin
    flush <= zero and branch;
    idexFlush <= flush;
    exmemFlush <= flush;
end architecture arch;
