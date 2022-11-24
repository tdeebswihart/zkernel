pub const cpu = @import("raspberrypi/cpu.zig");
pub const memory = @import("raspberrypi/memory.zig");
const board = switch (@import("build_options").board) {
    .rpi3 => @import("devices/bcm/bcm2837.zig"),
    .rpi4 => @import("devices/bcm/bcm2711.zig"),
};

const Uart = @import("devices/pl011/uart.zig");

comptime {
    @import("std").testing.refAllDecls(@This());
}

pub const console = Uart.new(memory.PL011_UART_START);

pub fn init() void {
    comptime {
        _ = cpu.BOOT_CORE_ID;
    }

    // Set the UART on GPIO pins 14 & 15
    board.gpio.GPFSEL1.write(.{
        .fsel14 = .txd0,
        .fsel15 = .rxd0,
    });

    board.gpio.setupUart1();
    console.init();
}
