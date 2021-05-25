const platform = @import("platform/platform.zig");

comptime {
    _ = platform;
    _ = platform.cpu;
}

/// Kernel entrypoint
pub fn main() noreturn {
    platform.init();
    unreachable;
}
