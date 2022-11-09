pub const cpu = @import("builtin").cpu;
usingnamespace switch (cpu.arch) {
    .aarch64 => @import("platform/aarch64/aarch64.zig"),
    else => @compileError("unsupported architecture"),
};
