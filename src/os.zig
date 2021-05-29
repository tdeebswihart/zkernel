pub const platform = @import("platform.zig");
pub const memory = @import("memory.zig");
pub const bsp = @import("bsp.zig");
pub const console = bsp.console;

comptime {
    _ = platform.cpu;
}


/// Kernel entrypoint
pub fn main() noreturn {
    platform.init();

    console.log("[0] platform init");

    platform.cpu.hang();
}
