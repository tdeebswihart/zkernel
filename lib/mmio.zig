pub fn Register(comptime Read: type, comptime Write: type) type {
    return struct {
        raw_ptr: *volatile Read,

        const Self = @This();

        pub inline fn at(address: usize) @This() {
            return @This(){ .raw_ptr = @intToPtr(*volatile Read, address) };
        }

        pub inline fn read(self: @This()) Read {
            return self.raw_ptr.*;
        }

        pub inline fn write(self: @This(), value: Write) void {
            self.raw_ptr.* = @bitCast(Read, value);
        }
    };
}

pub const RegisterBank = struct {
    base: usize,

    /// Create the base register bank
    pub fn at(comptime base: comptime_int) @This() {
        return .{ .base = base };
    }

    /// Make a smaller register sub-bank out of a bigger one
    pub fn sub(self: @This(), comptime offset: comptime_int) @This() {
        return .{ .base = self.base + offset };
    }

    /// Define a single register
    pub fn reg(comptime self: @This(), comptime offset: comptime_int, comptime Read: type, comptime Write: type) Register(Read, Write) {
        return Register(Read, Write).at(self.base + offset);
    }
};
