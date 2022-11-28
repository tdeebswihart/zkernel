pub const RegisterBank = @import("../../../../libk.zig").mmio.RegisterBank;
pub const resistorSelect = @import("../gpio.zig").resistorSelect;

const GPIO = RegisterBank.at(0x7e20_0000);

const fsel = u3;
// we only need gpio pins 14 and 15
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

pub const GPIO_PUP_PDN_CNTRL_REG0 = GPIO.reg(0xe4, u32, packed struct {
    ignored: u28,
    gpio14: resistorSelect,
    gpio15: resistorSelect,
});
