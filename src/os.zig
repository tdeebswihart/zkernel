const libk = @import("libk");

pub const debug = true;

comptime {
    @export(main, .{ .name = "kmain", .linkage = .Strong });
}

/// Kernel entrypoint
pub fn main() callconv(.C) noreturn {
    libk.init() catch unreachable;
    libk.console.info("platform initialized", .{});

    libk.platform.cpu.hang();
}

comptime {
    @import("std").testing.refAllDecls(@This());
}
