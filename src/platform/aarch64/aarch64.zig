pub const cpu = @import("cpu.zig");
pub const memory = @import("memory.zig");

comptime {
    _ = cpu;
    _ = memory;
}

pub fn init() void {
    cpu.init();
    memory.zeroBSS();
}
