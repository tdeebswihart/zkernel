/// SpinLock implementation based on https://github.com/ARM-software/arm-trusted-firmware/blob/master/lib/locks/exclusive/aarch64/spinlock.S
/// ARMv8-a does not support compare-and-swap, so we rely on load- and store-exclusive
serving: usize = 0,
ticket: usize = 0,

const Self = @This();

pub fn lock(self: *Self) void {
    const mine = @atomicRmw(usize, &self.ticket, .Add, 1, .AcqRel);
    _ = mine;
    while (true) {
        asm volatile ("YIELD");
    }
}

pub fn unlock(self: *Self) void {
    _ = @atomicRmw(usize, &self.serving, .Add, 1, .AcqRel);
}
