pub const bsp = @import("bsp.zig");
pub const platform = @import("platform.zig");
pub const memory = @import("memory.zig");
pub const Console = @import("console.zig");

pub const debug = true;

/// Kernel entrypoint
pub fn kmain() linksection(".text.kmain") callconv(.C) noreturn {
    platform.init();

    var console = Console.init();

    console.info("platform initialized", .{});

    platform.cpu.hang();
}

comptime {
    @import("std").testing.refAllDecls(@This());
}
