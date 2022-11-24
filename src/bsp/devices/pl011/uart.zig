const mmio = @import("root").lib.mmio;
const RegisterBank = mmio.RegisterBank;
const Register = mmio.Register(u32, u32);
const cpu = @import("root").platform.cpu;

// TODO: make these proper structs and things
pub const Offset = enum(u32) {
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
const FR_TXFF: u32 = 1 << 5;
const FR_RXFE: u32 = 1 << 4;

addr: usize,

const Self = @This();

pub fn new(comptime base: comptime_int) Self {
    return .{
        .addr = base,
    };
}

pub fn init(self: Self) void {
    self.flush();

    self.reg(.CR).write(0);
    self.reg(.ICR).write(0);

    self.reg(.IBRD).write(3);
    self.reg(.FBRD).write(16);
    // 8bit words | FifosEnabled
    self.reg(.LCRH).write(0b11 << 5 | 1 << 4);

    // Turn the UART on.
    // RXE enabled | TXE enabled | UART enabled
    self.reg(.CR).write(1 << 9 | 1 << 8 | 1);
}

inline fn reg(self: Self, comptime offset: Offset) Register {
    return Register.at(self.addr + @enumToInt(offset));
}

fn flush(self: Self) void {
    const fr = self.reg(.FR);
    while (fr.read() & FR_BUSY > 0) {
        cpu.nop();
    }
}

inline fn writeChar(self: Self, c: u8) void {
    const fr = self.reg(.FR);
    while (fr.read() & FR_TXFF > 0) {
        cpu.nop();
    }
    self.reg(.DR).write(@intCast(u32, c));
}

pub fn write(self: Self, buf: []const u8) void {
    for (buf) |c| {
        self.writeChar(c);
    }
}

inline fn readChar(self: Self) u8 {
    const fr = self.reg(.FR);
    while (fr.read() & FR_RXFE > 0) {
        cpu.nop();
    }
    return @truncate(u8, self.reg(.DR).read());
}
