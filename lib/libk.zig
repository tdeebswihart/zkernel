pub const bsp = @import("bsp.zig");
pub const platform = @import("platform.zig");
pub const memory = @import("memory.zig");
pub const mmio = @import("mmio.zig");

pub const SpinLock = @import("spinlock.zig");
const Console = @import("console.zig");

pub const console: Console = Console.init();

comptime {
    @export(platform.cpu.kinit, .{ .name = "kinit", .linkage = .Strong });
}

pub fn init() !void {
    platform.init();
    bsp.init();
}

comptime {
    @import("std").testing.refAllDecls(@This());
}
