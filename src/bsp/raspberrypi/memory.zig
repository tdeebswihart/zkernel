pub const BASE: usize = 0x3F00_0000; // TODO: how to select board?
pub const GPIO_BASE: usize = BASE + 0x0020_0000;
pub const PL011_UART_START: usize = BASE + 0x0020_1000;
pub const MAILBOX_BASE: usize = BASE + 0x0000_B880;

comptime {
    @import("std").testing.refAllDecls(@This());
}
