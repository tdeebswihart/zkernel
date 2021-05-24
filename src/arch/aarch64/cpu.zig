const root = @import("root");

extern var __bss_start: u8;
extern var __bss_end: u8;
extern var __end_init: u8;
extern var boot_core_id: u8;

pub fn clearBss() void {
    @memset(@as(*volatile [1]u8, &__bss_start), 0, @ptrToInt(&__bss_end) - @ptrToInt(&__bss_start));
}

export fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\.arm
            //\\.cpu arm7tdmi
            \\   1: wfe
            \\   b 1b
    );
    unreachable;
}

pub fn init() void {}
