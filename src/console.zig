const os = @import("root");
const bsp = @import("bsp.zig");
const sync = @import("lib.zig").sync;
const fmt = @import("std").fmt;

pub const Console = struct {
    guard: sync.Mutex,
    // Implements the pseudo-interface required by `std.fmt.format`
    pub const Error = anyerror;

    const Self = @This();

    pub fn init() Self {
        return Self{
            .guard = .{},
        };
    }

    pub fn writeAll(self: *Self, str: []const u8) !void {
        self.guard.lock();
        defer self.guard.unlock();

        bsp.console.writeString(str);
    }

    pub fn writeByteNTimes(self: *Self, val: u8, times: usize) !void {
        self.guard.lock();
        defer self.guard.unlock();

        var i: usize = 0;
        while (i < times) : (i += 1) {
            bsp.console.putchar(val);
        }
    }

    pub fn info(self: *Self, comptime format: []const u8, args: anytype) void {
        fmt.format(self, "[INFO]  " ++ format ++ "\r\n", args) catch unreachable;
    }

    pub fn err(self: *Self, comptime format: []const u8, args: anytype) void {
        fmt.format(self, "[ERROR]  " ++ format ++ "\r\n", args) catch unreachable;
    }

    usingnamespace if (os.debug) struct {
        pub fn debug(self: *Self, comptime format: []const u8, args: anytype) void {
            fmt.format(self, "[DEBUG] " ++ format ++ "\r\n", args) catch unreachable;
        }
    } else struct {
        pub fn debug(_: *Self, comptime _: []const u8, _: anytype) void {}
    };
};
