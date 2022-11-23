entity control_hazard is
    port (
        branch: in bit;
        zero: in bit;
        ifidFlush: out bit;
        idexFlush: out bit
    );
end entity;

architecture arch of control_hazard is
    signal flush: bit;
begin
    flush <= zero and branch;
    ifidFlush <= flush;
    idexFlush <= flush;
end architecture arch;
