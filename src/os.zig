pub const bsp = @import("bsp.zig");
pub const platform = @import("platform.zig");
pub const memory = @import("memory.zig");
pub const lib = @import("lib.zig");
pub const Console = @import("console.zig");

pub const debug = true;

comptime {
    @export(platform.cpu.kinit, .{ .name = "kinit", .linkage = .Strong });
    @export(main, .{ .name = "kmain", .linkage = .Strong });
    _ = bsp.console;
}

/// Kernel entrypoint
pub fn main() callconv(.C) noreturn {
    platform.init();
    bsp.init();

    var console = Console.init();

    console.info("platform initialized", .{});

    platform.cpu.hang();
}

comptime {
    @import("std").testing.refAllDecls(@This());
}
