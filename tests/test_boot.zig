pub const platform = @import("../src/platform.zig");
pub const platform = @import("platform.zig");
pub const Console = @import("console.zig").Console;

pub fn main() noreturn {
    platform.init();

    var console = Console.init();

    console.info("successful boot", .{});
}
