pub const platform = @import("platform.zig");
pub const memory = @import("memory.zig");
pub const bsp = @import("bsp.zig");

comptime {
    _ = platform.cpu;
}

/// Kernel entrypoint
pub fn main() noreturn {
    platform.init();
    memory.init();

    platform.cpu.hang();
}
