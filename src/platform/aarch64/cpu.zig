const root = @import("root");
const arm = @import("assembly.zig");
const bsp = @import("root").bsp;

pub fn entryPoint() callconv(.Naked) noreturn {
    const core = asm volatile (
        \\ mrs x1, MPIDR_EL1
        \\ and x1, x1, 0b11
        : [ret] "={x1}" (-> u64),
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
pub inline fn hang() noreturn {
    while (true) {
        arm.wfe();
    }
}

pub fn relax() void {
    asm volatile ("YIELD");
}

// pub const InterruptState = bool;
//
// pub fn get_and_disable_interrupts() InterruptState {
//     var daif = asm volatile("MRS %[val], DAIF" : [val] "=r" (->u64));
//     asm volatile ("MSR DAIFSET")
// }

pub fn delay(cycles: usize) void {
    var n: usize = 0;
    while (n < cycles) : (n += 1) {
        arm.nop();
    }
}
