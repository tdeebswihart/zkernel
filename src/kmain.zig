const std = @import("std");
const arch = @import("arch.zig");

comptime {
    asm (
        \\.section .text.boot
        \\_start:
        \\   1: wfe
        \\   b 1b
        \\ .size _start, . - _start
        \\ .type _start, function
        \\ .global _start
    );
}

export fn kmain() noreturn {
    unreachable;
}
