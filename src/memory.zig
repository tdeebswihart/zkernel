const platform = @import("platform.zig");

comptime {
    @import("std").testing.refAllDecls(@This());
}
