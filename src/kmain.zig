const arch = @import("arch.zig").Arch.init();

comptime {
    _ = arch;
}

/// Kernel entrypoint
export fn kmain() noreturn {
    unreachable;
}
