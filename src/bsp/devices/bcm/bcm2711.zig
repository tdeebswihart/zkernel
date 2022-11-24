const register = @import("root").lib.register;
pub const RegisterBank = @import("root").lib.mmio.RegisterBank;
pub const MMIO_BASE = 0x3F000000;
const MMIO_BANK = RegisterBank(0x3F000000);

const AUX_BANK = MMIO_BANK.sub(0x215000);
pub const AUX_ENABLES = AUX_BANK.reg(0x04);
pub const AUX_MU_IO = AUX_BANK.reg(0x40);
pub const AUX_MU_IER = AUX_BANK.reg(0x44);
pub const AUX_MU_IIR = AUX_BANK.reg(0x48);
pub const AUX_MU_LCR = AUX_BANK.reg(0x4C);
pub const AUX_MU_MCR = AUX_BANK.reg(0x50);
pub const AUX_MU_LSR = AUX_BANK.reg(0x54);
pub const AUX_MU_MSR = AUX_BANK.reg(0x58);
pub const AUX_MU_SCRATCH = AUX_BANK.reg(0x5C);
pub const AUX_MU_CNTL = AUX_BANK.reg(0x60);
pub const AUX_MU_STAT = AUX_BANK.reg(0x64);
pub const AUX_MU_BAUD = AUX_BANK.reg(0x68);

const GPIO_BANK = MMIO_BANK.sub(0x7e20_0000);
pub const GPFSEL0 = GPIO_BANK.reg(0x00);
pub const GPFEL1 = GPIO_BANK.reg(0x04);
pub const GPPUD = GPIO_BANK.reg(0x94);
pub const GPPUDCLK0 = GPIO_BANK.reg(0x98);

const MBOX_BANK = MMIO_BANK.sub(0xB880);
pub const MBOX_READ = MBOX_BANK.reg(0x00);
pub const MBOX_CONFIG = MBOX_BANK.reg(0x1C);
pub const MBOX_WRITE = MBOX_BANK.reg(0x20);
pub const MBOX_STATUS = MBOX_BANK.reg(0x18);
