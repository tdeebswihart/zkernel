pub export const BOOT_CORE_ID: u8 linksection(".text._start_args") = 0;

comptime {
    @import("std").testing.refAllDecls(@This());
}
