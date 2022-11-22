pub extern var __bss_start: u64;
pub extern var __bss_end: u64;
pub extern var __code_start: u64;
pub extern var __code_end_exclusive: u64;

// Zero a range
pub fn zeroBSS() void {
    @memset(@as(*volatile [1]u8, @intToPtr(*u8, __bss_start)), 0, @ptrToInt(&__bss_end) - @ptrToInt(&__bss_start));
}
