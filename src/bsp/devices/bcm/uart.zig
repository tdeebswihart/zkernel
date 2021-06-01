const opts = @import("build_options");
const board = @import(switch (opts.board) {
    .rpi3 => "bcm2837",
    .rpi4 => "bcm2711",
    } ++ "/board.zig");

const PL011 = struct {
    pub fn init() PL011 {
        // Set the UART on GPIO pins 14 & 15
        board.gpio.GPFSEL1.write(.{
            .fsel14 = .txd0,
            .fsel15 = .rxd0,
        });

        board.gpio.setupUart1();
    }
};
