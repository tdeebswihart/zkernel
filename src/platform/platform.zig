const arch = @import("builtin").arch;
usingnamespace @import(
  switch(arch) {
    .aarch64 => "aarch64/aarch64.zig",
    else => @compileError("unsupported architecture"),
  }
);
