pub const bsp = @import("bsp.zig");
pub const platform = @import("platform.zig");
pub const memory = @import("memory.zig");
pub const Console = @import("console.zig").Console;

pub const debug = true;

comptime {
    _ = platform.cpu;
}


/// Kernel entrypoint
pub fn main() noreturn {
    platform.init();

    var console = Console.init();

    console.debug("platform initialized", .{});

    platform.cpu.hang();
}
