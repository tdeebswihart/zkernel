pub const mmio = @import("root").lib.mmio;
pub const RegisterBank = mmio.RegisterBank;
pub const Register = mmio.Register;

fn reg32(comptime bank: RegisterBank, comptime base: comptime_int) Register {
    return bank.reg(base, u32, u32);
}

pub const Offset = enum {
    DR = 0x0,
    FR = 0x18,
    IBRD = 0x24,
    FBRD = 0x28,
    LCRH = 0x2c,
    CR = 0x30,
    IFLS = 0x34,
    IMSC = 0x38,
    ICR = 0x44,
    DMACR = 0x48,
};

const FR_BUSY: u32 = 1 << 3;
const LCR_STP2: u32 = 1 << 3;
const LCR_FEN: u32 = 1 << 4;
const CR_EN: u32 = 1 << 0;
const CR_TXEN: u32 = 1 << 8;

pub const Uart = packed struct {
    addr: usize,
    baseClock: u32,
    baudrate: u32,
    dataBits: u32,
    stopBits: u32,

    const Self = @This();
    pub fn init(comptime base: comptime_int, comptime baseClock: comptime_int) Self {
        var uart: Self =  .{
            .addr = base,
            .baseClock = baseClock,
            .baudrate = 115200,
            .dataBits = 8,
            .stopBits = 1,
        };

        uart.wait_tx_complete();
        uart.reset();

        return uart;
    }

    fn reg(self: Self, comptime offset: comptime_int) callconv(.Inline) Register {
        return Register(u32, u32).at(self.add + offset);
    }

    pub fn wait_tx_complete(self: Self) void {
        const fr = self.reg(Offset.FR);
        var flags = fr.read();
        while (flags & FR_BUSY == 0) : (flags = fr.read()) {}
    }

    pub fn reset(self. Self) void {
        const cr = self.reg(.cr);
        const lcrh = self.reg(.LCRH);

        cr.write(cr.read() & !0x1);
        self.wait_tx_complete();
        // TODO: either finish implementing this or go back to rust and use crates
        // that do some of this for me /shrug.
        // Implementing a PL011 UART library is not particularly interesting
    }
};
