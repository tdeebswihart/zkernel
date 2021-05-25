const arch = @import("builtin").cpu.arch;
usingnamespace @import(switch (arch) {
    .aarch64 => "platform/aarch64/aarch64.zig",
    else => @compileError("unsupported architecture"),
});
