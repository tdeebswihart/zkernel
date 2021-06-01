pub const RegisterBank = @import("root").lib.mmio.RegisterBank;
pub const resistorSelect = @import("../gpio.zig").resistorSelect;
pub const cpu = @import("root").platform.cpu;

const GPIO = RegisterBank.at(0x3F20_0000);

const GPFSEL1 = GPIO.reg(0x04, u32, packed struct {
    fsel10: fsel,
    fsel11: fsel,
    fsel12: fsel,
    fsel13: fsel,
    fsel14 = packed enum(u3) {
        txd0 = 0b000,
        sd6 = 0b001,
        dpi_d10 = 0b010,
        spi5_mosi = 0b011,
        cts5 = 0b100,
        txd1 = 0b101,
    },
    fsel15 = packed enum(u3) {
        rxd0 = 0b000,
        sd7 = 0b001,
        dpi_d11 = 0b010,
        spi5_sclk = 0b011,
        rts5 = 0b100,
        rxd1 = 0b101,
    },
    fsel16: fsel,
    fsel17: fsel,
    fsel18: fsel,
    fsel19: fsel,
    reserved: u2,
});

pub const resistorSelect = packed enum(2) {
        off = 0b00,
        pulldown = 0b01,
        pullup = 0b10,
};

pub const GPPUD = GPIO_BANK.reg(0x94, u32, packed struct {
    pud: resistorSelect,
    ignored: u30,
});

pub const clockedPin = packed enum(u1) {
    off = 0,
    assertClock = 1,
};

pub const GPPUDCLK0 = GPIO_BANK.reg(0x98, u32, packed struct {
    ignored: u14,
    gpio14: clockedPin,
    gpio15: clockedPin,
    alsoIgnored: u16,
});

pub fn setupUart1() void {
    GPPUD.write(.{
        .pud = .off,
    });
    // The following comment is taken from the rust tutorial at
    // https://github.com/rust-embedded/rust-raspberrypi-OS-tutorials/blob/f6f668c7810d018fb9bf7b501754c07f15120dc1/05_drivers_gpio_uart/src/bsp/device_driver/bcm/bcm2xxx_gpio.rs
    //
    // The BCM2837 docs state to wait 150 cycles between steps, but it's 10 at night and I
    // don't have the energy to argue with something that works
    //
    // Make an educated guess for a good delay value (Sequence described in the BCM2837
    // peripherals PDF).
    //
    // - According to Wikipedia, the fastest Pi3 clocks around 1.4 GHz.
    // - The Linux 2837 GPIO driver waits 1 µs between the steps.
    //
    // So lets try to be on the safe side and default to 2000 cycles, which would equal 1 µs
    // would the CPU be clocked at 2 GHz.    cpu.delay(2000);
    cpu.delay(2000);

    GPPUDCLK0.write(.{
        .gpio14 = .assertClock,
        .gpio15 = .assertClock,
    });

    cpu.delay(2000);

    GPPUD.write(.{
        .pud = .off,
    });

    GPPUDCLK0.write(0);
}
