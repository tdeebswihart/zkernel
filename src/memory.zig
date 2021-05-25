const platform = @import("platform.zig");

// Zero a range
pub fn zeroVolatile(start: u8, end: u8) void {
    @memset(@intToPtr([*]u8, start), 0, @ptrToInt(&end) - @ptrToInt(&start));
}

pub fn init() void {
    zeroVolatile(platform.memory.__bss_start, platform.memory.__bss_end);
}
