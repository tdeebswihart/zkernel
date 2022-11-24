const std = @import("std");
const os = @import("root");
const bsp = @import("bsp.zig");
const sync = @import("lib.zig").sync;
const fmt = @import("std").fmt;

comptime {
    std.testing.refAllDecls(@This());
}

//guard: sync.Mutex,
// Implements the pseudo-interface required by `std.fmt.format`
pub const WriteError = anyerror;

const Self = @This();

pub fn init() Self {
    return .{}; //.guard = .{} };
}

pub fn writeByteNTimes(self: *Self, val: u8, times: usize) !void {
    _ = self;
    //self.guard.lock();
    //defer self.guard.unlock();

    var i: usize = 0;
    while (i < times) : (i += 1) {
        bsp.console.putchar(val);
    }
}

pub fn write(self: *Self, bytes: []const u8) WriteError!usize {
    _ = self;
    //self.guard.lock();
    //defer self.guard.unlock();

    bsp.console.write(bytes);
    return bytes.len;
}

const Writer = std.io.Writer(*Self, WriteError, write);
pub fn writer(self: *Self) Writer {
    return .{ .context = self };
}

pub fn info(self: *Self, comptime format: []const u8, args: anytype) void {
    fmt.format(self.writer(), comptime "[INFO]  " ++ format ++ "\r\n", args) catch unreachable;
}

pub fn err(self: *Self, comptime format: []const u8, args: anytype) void {
    fmt.format(self.writer(), comptime "[ERROR]  " ++ format ++ "\r\n", args) catch unreachable;
}

pub usingnamespace if (os.debug) struct {
    pub fn debug(self: *Self, comptime format: []const u8, args: anytype) void {
        fmt.format(self.writer(), comptime "[DEBUG] " ++ format ++ "\r\n", args) catch unreachable;
    }
} else struct {
    pub fn debug(_: *Self, comptime _: []const u8, _: anytype) void {}
};
