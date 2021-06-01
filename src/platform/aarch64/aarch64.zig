pub const cpu = @import("cpu.zig");
pub const memory = @import("memory.zig");
pub const spinlock = @import("spinlock.zig");

pub fn init() void {
    cpu.init();
    memory.zeroBSS();
}
