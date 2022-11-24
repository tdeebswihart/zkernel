fn SysReg(comptime name: []const u8, comptime Val: type) type {
    return struct {
        // MSR Xt, <system_register> - Move the value in Xt to the system register
        pub inline fn set(val: Val) void {
            asm volatile ("msr " ++ name ++ ", %[v]"
                :
                : [v] "r" (val),
            );
        }
    };
}

pub const SPSR_EL2 = SysReg("spsr_el2", packed struct(u64) {
    _res0: u32 = 0,
    _ignored: u21 = 0,
    D: u1 = 0,
    A: u1 = 0,
    I: u1 = 0,
    F: u1 = 0,
    T: u1 = 0,
    _res0_5: u1 = 0,
    M: enum(u5) {
        EL0t = 0,
        EL1t = 4,
        EL1h = 5,
        EL2t = 8,
        EL2h = 9,
    } = .EL0t,
});

pub const ELR_EL2 = SysReg("elr_el2", u64);
pub const SP_EL1 = SysReg("sp_el1", u64);
pub const CNTVOFF_EL2 = SysReg("cntvoff_el2", u64);

pub const CNTHCTL_EL2 = SysReg("cnthctl_el2", packed struct(u64) {
    _ignored: u52 = 0,
    EL1PCTEN: u1 = 0,
    _res9: u9 = 0,
    EL1PCEN: u1 = 0,
    _res0: u1 = 0,
});

pub const SPSEL = SysReg("spsel", packed struct(u64) {
    _res: u63 = 0,
    SP: enum(u1) {
        EL0 = 0,
        ELx = 1,
    } = .EL0,
});

pub const HCR_EL2 = SysReg("hcr_el2", packed struct(u64) {
    _res: u32 = 0,
    RW: enum(u1) {
        EL1IsAarch32 = 0,
        EL1IsAarch64 = 1,
    } = .EL1IsAarch32,
    _rest: u31 = 0,
});
