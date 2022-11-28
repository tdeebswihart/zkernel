pub const bsp = @import("../src/bsp.zig");
pub const platform = @import("../src/platform.zig");
pub const memory = @import("../src/memory.zig");
pub const lib = @import("../src/lib.zig");
pub const Console = @import("../src/console.zig");
const qemu = @import("../src/bsp/devices/qemu.zig");

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

    console.info("success", .{});

    qemu.exitSuccess();
}

comptime {
    @import("std").testing.refAllDecls(@This());
}
