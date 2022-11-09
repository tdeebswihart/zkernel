const opts = @import("build_options");
const board = switch (opts.board) {
    .rpi3 => @import("bcm2837/board.zig"),
    .rpi4 => @import("bcm2711/board.zig"),
};

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
