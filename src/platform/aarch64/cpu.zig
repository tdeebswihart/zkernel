const root = @import("root");
const arm = @import("assembly.zig");
const bsp = @import("root").bsp;

fn prepareEL1Transition(boot_core_stack_end: u64) void {
    arm.CNTHCTL_EL2.set(.{ .EL1PCTEN = 1, .EL1PCEN = 1 });
    arm.CNTVOFF_EL2.set(0);
    arm.SPSR_EL2.set(.{ .D = 1, .A = 1, .I = 1, .F = 1, .M = .EL1h });
    arm.HCR_EL2.set(.{ .RW = .EL1IsAarch64 });
    arm.SPSEL.set(.{ .SP = .ELx });
    arm.SP_EL1.set(boot_core_stack_end);
}

pub fn kinit(phys_boot_core_stack_end_exclusive_addr: usize, main_addr: usize) callconv(.C) noreturn {
    prepareEL1Transition(phys_boot_core_stack_end_exclusive_addr);
    arm.ELR_EL2.set(main_addr);
    arm.eret();
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

pub inline fn nop() void {
    asm volatile ("nop");
}
