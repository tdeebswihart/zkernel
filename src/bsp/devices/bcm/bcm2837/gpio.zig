pub const RegisterBank = @import("root").lib.mmio.RegisterBank;
pub const cpu = @import("root").platform.cpu;

const GPIO = RegisterBank.at(0x3F20_0000);

const fsel = u3;

pub const GPFSEL1 = GPIO.reg(0x04, u32, packed struct(u32) {
    fsel10: fsel = 0,
    fsel11: fsel = 0,
    fsel12: fsel = 0,
    fsel13: fsel = 0,
    fsel14: enum(u3) {
        txd0 = 0b000,
        sd6 = 0b001,
        dpi_d10 = 0b010,
        spi5_mosi = 0b011,
        cts5 = 0b100,
        txd1 = 0b101,
    },
    fsel15: enum(u3) {
        rxd0 = 0b000,
        sd7 = 0b001,
        dpi_d11 = 0b010,
        spi5_sclk = 0b011,
        rts5 = 0b100,
        rxd1 = 0b101,
    },
    fsel16: fsel = 0,
    fsel17: fsel = 0,
    fsel18: fsel = 0,
    fsel19: fsel = 0,
    reserved: u2 = 0,
});

pub const GPPUD = GPIO.reg(0x94, u32, packed struct(u32) {
    pud: enum(u2) {
        off = 0b00,
        pullDown = 0b01,
        pullUp = 0b10,
    } = .off,
    ignored: u30 = 0,
});

pub const clockedPin = enum(u1) {
    off = 0,
    assertClock = 1,
};

pub const GPPUDCLK0 = GPIO.reg(0x98, u32, packed struct(u32) {
    ignored: u14 = 0,
    gpio14: clockedPin = .off,
    gpio15: clockedPin = .off,
    alsoIgnored: u16 = 0,
});

pub const GPIO_PUP_PDN_CTNRL_REG0 = GPIO.reg(0xE4, u32, packed struct(u32) {
    _res: u1 = 0,
    CNTRL15: enum(u2) {
        noResistor = 0b00,
        pullUp = 0b01,
    } = .noResistor,
    _res29: u1 = 0,
    CNTRL14: enum(u2) {
        noResistor = 0b00,
        pullUp = 0b01,
    } = .noResistor,
    _rest: u26 = 0,
});

pub fn setupUart() void {
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
    // would the CPU be clocked at 2 GHz.
    cpu.delay(2000);

    GPPUDCLK0.write(.{
        .gpio14 = .assertClock,
        .gpio15 = .assertClock,
    });

    cpu.delay(2000);

    GPPUD.write(.{
        .pud = .off,
    });

    GPPUDCLK0.write(.{});
}
