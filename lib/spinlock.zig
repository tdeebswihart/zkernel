const panic = @import("std").debug.panic;

serving: usize = 0,
ticket: usize = 0,

const Mutex = @This();

pub const Guard = struct {
    ticket: usize,
    lock: *Mutex,

    pub fn unlock(self: *Guard) void {
        const serving = @atomicRmw(usize, &self.lock.serving, .Add, 1, .AcqRel);
        if (serving != self.ticket) {
            panic("Ticket {d} released while {d} being served", .{ self.ticket, serving });
        }
        self.lock.* = undefined;
    }
};

pub fn lock(self: *Mutex) Guard {
    const mine = @atomicRmw(usize, &self.ticket, .Add, 1, .AcqRel);

    while (@atomicLoad(usize, &self.serving, .Acquire) != mine) {
        while (self.serving != mine) {
            asm volatile ("YIELD");
        }
    }
    return .{ .ticket = mine, .lock = self };
}
