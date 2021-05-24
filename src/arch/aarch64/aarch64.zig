pub const registers = @import("registers.zig");
pub const cpu = @import("cpu.zig");

pub fn init() void {
    cpu.init();
}
