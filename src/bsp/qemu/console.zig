const serialPort = @intToPtr(*volatile u8, 0x3F20_1000);

pub fn write(str: []const u8) void {
    for (str) |chr| {
        serialPort.* = chr;
    }
}

pub inline fn putchar(chr: u8) void {
    serialPort.* = chr;
}
