pub const registers = @import("registers.zig");
pub const cpu = @import("cpu.zig");
pub const memory = @import("memory.zig");

comptime {
    _ = cpu;
    _ = memory;
    _ = registers;
}

pub fn init() void {
    cpu.init();
    memory.zeroBSS();
}
