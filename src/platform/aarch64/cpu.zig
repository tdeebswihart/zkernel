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

    // Set the stack pointer
    asm volatile (
        \\ adrp x0, __boot_core_stack_end_exclusive
        \\ add x0, x0, #:lo12:__boot_core_stack_end_exclusive
        \\ mov sp, x0
    );

    if (@typeInfo(@TypeOf(root.main)).Fn.return_type != noreturn) {
        @compileError("expected return type of main to be 'noreturn'");
    }

    @call(.{ .modifier = .always_inline }, root.main, .{});
}

pub fn init() void {}

// Hang forever
pub fn hang() callconv(.Inline) noreturn {
    while (true) {
        as.wfe();
    }
}
