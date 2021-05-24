const builtin = @import("builtin");

pub const Arch = struct {
    setup: fn() void,

    pub fn init() Arch {
        var arch = Arch {
            .setup = nil_setup,
        };
        comptime {
            switch (builtin.cpu.arch) {
                .aarch64 =>  {
                    const a64 = @import("arch/aarch64/aarch64.zig");
                    arch = Arch {
                        .setup = a64.init,
                    };
                },
                else => @compileError("unsupported architecture"),
            };
        }
        return arch;
    }
};

fn nil_setup() void {}
