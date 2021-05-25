pub const registers = @import("registers.zig");
pub const cpu = @import("cpu.zig");

comptime {
    _ = cpu;
    _ = registers;
}

pub fn init() void {
    cpu.init();
}
