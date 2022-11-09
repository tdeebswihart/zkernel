pub const RegisterBank = @import("root").lib.mmio.RegisterBank;
pub const resistorSelect = @import("../gpio.zig").resistorSelect;

const GPIO = RegisterBank.at(0x7e20_0000);

const fsel = u3;
// we only need gpio pins 14 and 15
const GPFSEL1 = GPIO.reg(0x04, u32, extern struct {
    fsel10: fsel,
    fsel11: fsel,
    fsel12: fsel,
    fsel13: fsel,
    fsel14: packed enum(u3) {
        txd0 = 0b000,
        sd6 = 0b001,
        dpi_d10 = 0b010,
        spi5_mosi = 0b011,
        cts5 = 0b100,
        txd1 = 0b101,
    },
    fsel15: packed enum(u3) {
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

const GPIO_PUP_PDN_CNTRL_REG0 = GPIO.reg(0xe4, u32, packed struct {
    ignored: u28,
    gpio14: resistorSelect,
    gpio15: resistorSelect,
});
