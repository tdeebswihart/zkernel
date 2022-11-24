pub const cpu = @import("cpu.zig");
pub const memory = @import("memory.zig");
pub const SpinLock = @import("spinlock.zig");

pub fn init() void {
    cpu.init();
}

comptime {
    @import("std").testing.refAllDecls(@This());
}
