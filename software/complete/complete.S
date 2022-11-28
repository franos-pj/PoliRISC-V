    lw x1, 0(x0)
    beq x1, x0, nottaken
    lw x2, 8(x0)
    lw x5, 16(x0)
    lw x9, 24(x0)
    lw x11, 32(x0)
    lw x17, 40(x0)
    beq x0, x0, taken
    add x1, x2, x3
    add x4, x5, x6
    add x7, x9, x9
    add x10, x11, x12
taken:
    add x16, x17, x18
    add x19, x17, x16
    add x0, x0, x0
    sw x16, 48(x0)
nottaken:
    add x20, x0, x0
    sw x16, 56(x0)
