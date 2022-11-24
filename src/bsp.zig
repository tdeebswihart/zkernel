// Some day this will be by device but meh
pub usingnamespace @import("bsp/raspberrypi.zig");

comptime {
    @import("std").testing.refAllDecls(@This());
}
