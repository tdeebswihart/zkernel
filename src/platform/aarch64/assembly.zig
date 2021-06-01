pub fn wfe() callconv(.Inline) void {
    asm volatile ("wfe");
}

pub fn nop() callconv(.Inline) void {
    asm volatile ("nop");
}
