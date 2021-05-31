const serialPort = @intToPtr(*volatile u8, 0x3F20_1000);

pub fn writeString(str: []const u8) void {
    for (str) |chr| {
        serialPort.* = chr;
    }
}

pub fn putchar(chr: u8) callconv(.Inline) void {
    serialPort.* = chr;
}
