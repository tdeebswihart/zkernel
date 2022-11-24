const cpu = @import("root").platform.cpu;

pub const Mutex = struct {
    serving: usize = 0,
    ticket: usize = 0,

    const Self = @This();

    pub fn lock(self: *Self) void {
        const mine = @atomicRmw(usize, &self.ticket, .Add, 1, .AcqRel);
        while (true) {
            // FIXME: disable interrupts and store the old state
            if (@atomicLoad(usize, &self.serving, .Acquire) == mine) {
                return;
            }
            // FIXME: restore the old interrupt state
            cpu.relax();
        }
    }

    pub fn unlock(self: *Self) void {
        // FIXME: require the interrupt state to set and set it
        _ = @atomicRmw(usize, &self.serving, .Add, 1, .AcqRel);
    }
};
