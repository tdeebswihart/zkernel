const std = @import("std");
const root = @import("root");
const bsp = @import("bsp.zig");
const SpinLock = @import("libk.zig").SpinLock;
const fmt = @import("std").fmt;

// Implements the pseudo-interface required by `std.fmt.format`
pub const WriteError = anyerror;

const Self = @This();

//lock: SpinLock,

pub fn init() Self {
    return .{};
}

pub fn writeByteNTimes(self: *const Self, val: u8, times: usize) !void {
    _ = self;
    // var guard = self.lock.lock();
    // defer guard.unlock();

    var i: usize = 0;
    while (i < times) : (i += 1) {
        bsp.console.putchar(val);
    }
}

pub fn write(self: *const Self, bytes: []const u8) WriteError!usize {
    _ = self;
    // var guard = self.lock.lock();
    // defer guard.unlock();

    bsp.console.write(bytes);
    return bytes.len;
}

const Writer = std.io.Writer(*const Self, WriteError, write);
pub fn writer(self: *const Self) Writer {
    return .{ .context = self };
}

pub fn info(self: *const Self, comptime format: []const u8, args: anytype) void {
    fmt.format(self.writer(), comptime "[INFO]  " ++ format ++ "\r\n", args) catch unreachable;
}

pub fn err(self: *const Self, comptime format: []const u8, args: anytype) void {
    fmt.format(self.writer(), comptime "[ERROR]  " ++ format ++ "\r\n", args) catch unreachable;
}

pub usingnamespace if (root.debug) struct {
    pub fn debug(self: *const Self, comptime format: []const u8, args: anytype) void {
        fmt.format(self.writer(), comptime "[DEBUG] " ++ format ++ "\r\n", args) catch unreachable;
    }
} else struct {
    pub fn debug(_: *const Self, comptime _: []const u8, _: anytype) void {}
};
