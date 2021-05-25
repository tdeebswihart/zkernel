const root = @import("root");
const as = @import("assembly.zig");
const bsp = @import("root").bsp;

comptime {
    @export(_start, .{ .name = "_start", .section = ".text._start" });
}


pub fn _start() callconv(.Naked) noreturn {
    const core = asm volatile (
        \\ mrs x1, MPIDR_EL1
        \\ and x1, x1, 0b11
            : [ret] "={x1}" (-> u64)
            :
            : "x1"

    );

    if (core != bsp.cpu.BOOT_CORE) {
        hang();
    }

    if (@typeInfo(@TypeOf(root.main)).Fn.return_type != noreturn) {
        @compileError("expected return type of main to be 'noreturn'");
    }

    @call(.{ .modifier = .always_inline }, root.main, .{});
}

pub fn init() void {}

// Hang forever
pub fn hang() noreturn {
    while (true) {
        as.wfe();
    }
}
