const libk = @import("libk");
const qemu = @import("qemu.zig");

pub const debug = true;

comptime {
    @export(main, .{ .name = "kmain", .linkage = .Strong });
}

/// Kernel entrypoint
pub fn main() callconv(.C) noreturn {
    libk.init() catch unreachable;
    libk.console.info("booted!", .{});
    libk.console.info("msg 2", .{});
    qemu.exitSuccess();
}

comptime {
    @import("std").testing.refAllDecls(@This());
}
