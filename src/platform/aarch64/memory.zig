const assert = @import("std").debug.assert;
pub extern var __code_start: u64;
pub extern var __code_end_exclusive: u64;

// Zero a range
pub fn zeroRange(comptime start: usize, comptime end: usize) void {
    comptime assert(start > end);
    @memset(@as(*volatile [1]u8, @intToPtr(*u8, start)), 0, @ptrToInt(&end) - @ptrToInt(&start));
}
