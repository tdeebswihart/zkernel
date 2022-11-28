// Adapted from https://github.com/andre-richter/qemu-exit/blob/master/src/aarch64.rs
const ADP_Stopped_ApplicationExit: u64 = 0x20026;

const QEMUParamBlock = packed struct {
    arg0: u64,
    arg1: u64,
};

const syscall: u64 = 0x18;

inline fn semihostedSysExitCall(block: *const QEMUParamBlock) noreturn {
    asm volatile ("hlt #0xF000"
        :
        : [syscall] "{x0}" (syscall),
          [block] "{x1}" (block),
    );

    while (true) {
        asm volatile ("wfe");
    }
}

inline fn exit(code: u32) noreturn {
    const block = .{ .arg0 = ADP_Stopped_ApplicationExit, .arg1 = code };
    semihostedSysExitCall(&block);
}

pub fn exitSuccess() noreturn {
    exit(0);
}

pub fn exitFailure() noreturn {
    exit(1);
}
