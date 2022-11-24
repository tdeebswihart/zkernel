pub usingnamespace @import("registers.zig");

pub inline fn wfe() void {
    asm volatile ("wfe");
}

pub inline fn nop() void {
    asm volatile ("nop");
}

pub inline fn eret() noreturn {
    asm volatile ("eret");
    unreachable;
}
