const serialPort = @intToPtr(*volatile u8, 0x3F20_1000);

pub fn writeString(str: []const u8) void {
    for (str) |chr| {
        serialPort.* = chr;
    }
}

pub fn log(str: []const u8) void {
    @call(.{ .modifier = .always_inline }, writeString, .{str});
    serialPort.* = '\r';
    serialPort.* = '\n';
}
