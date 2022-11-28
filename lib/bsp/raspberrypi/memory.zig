const END_INCLUSIVE: usize = 0xFFFF_FFFF;
const DEFAULT_LOAD_ADDRESS: usize = 0x8_0000;
const UART0_OFFSET: usize = 0x0020_1000;
const MAILBOX_OFFSET: usize = 0x0000_B880;
const GPIO_OFFSET = 0x0020_0000;

fn MMIO(comptime base_addr: u64) type {
    return struct {
        pub const GPIO_START: usize = base_addr + GPIO_OFFSET;
        pub const PL011_UART_START: usize = base_addr + UART0_OFFSET;
        pub const MAILBOX_START: usize = base_addr + MAILBOX_OFFSET;
    };
}

pub const mmio = MMIO(switch (@import("build_options").board) {
    .rpi3 => 0x3F00_0000,
    .rpi4 => 0xFE00_0000,
});

comptime {
    @import("std").testing.refAllDecls(@This());
}
