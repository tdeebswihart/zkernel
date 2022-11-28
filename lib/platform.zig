const builtin = @import("builtin");
pub usingnamespace switch (builtin.cpu.arch) {
    .aarch64 => @import("platform/aarch64/aarch64.zig"),
    else => @compileError("unsupported architecture"),
};
