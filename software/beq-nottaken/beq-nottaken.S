    lw x1, 0(x0)
    lw x2, 8(x0)
    lw x5, 16(x0)
    lw x9, 24(x0)
    lw x11, 32(x0)
    lw x17, 40(x0)
    beq x1, x0, nottaken
    add x1, x2, x3
    add x4, x5, x6
    add x7, x9, x9
    add x10, x11, x12
nottaken:
	add x16, x17, x18
