const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *std.build.Builder) !void {
    const want_nodisplay = b.option(bool, "nodisplay", "No display for qemu") orelse false;
    const want_monitor = b.option(bool, "monitor", "Monitor chardev") orelse false;
    const want_gdb = b.option(bool, "gdb", "Wait for GDB connections on 1234") orelse false;
    const want_asm = b.option(bool, "disasm", "Dump asm as it is executed") orelse false;
    const board = b.option(enum {
        rpi3,
        rpi4,
    }, "board", "Board to build for") orelse .rpi3;
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const kernel = b.addExecutable("kernel", "src/os.zig");

    var disabled_features = std.Target.Cpu.Feature.Set.empty;
    var enabled_features = std.Target.Cpu.Feature.Set.empty;

    const features = std.Target.aarch64.Feature;
    disabled_features.addFeature(@enumToInt(features.fp_armv8));
    disabled_features.addFeature(@enumToInt(features.crypto));
    disabled_features.addFeature(@enumToInt(features.neon));
    kernel.code_model = .small;

    kernel.disable_stack_probing = true;
    kernel.setTarget(.{
        .cpu_arch = .aarch64,
        .cpu_model = .{ .explicit = switch (board) {
            .rpi3 => &std.Target.aarch64.cpu.cortex_a53,
            .rpi4 => &std.Target.aarch64.cpu.cortex_a72,
        } },
        .os_tag = std.Target.Os.Tag.freestanding,
        .abi = std.Target.Abi.none,
        .cpu_features_sub = disabled_features,
        .cpu_features_add = enabled_features,
    });

    kernel.setLinkerScriptPath(.{ .path = "src/bsp/raspberrypi/linker.ld" });
    kernel.setBuildMode(mode);
    kernel.setOutputDir("zig-cache");
    kernel.install();

    b.default_step.dependOn(&kernel.step);
    const kernel_name = "kernel8.img";
    const kernel_obj = b.fmt("{s}/{s}", .{ b.cache_root, kernel.out_filename });

    const run_objcopy = b.addSystemCommand(&[_][]const u8{
        "llvm-objcopy",   kernel_obj,
        "--only-section", ".text",
        "-O",             "binary",
        kernel_name,
    });
    run_objcopy.step.dependOn(&kernel.step);

    b.default_step.dependOn(&run_objcopy.step);

    const run_objdump = b.addSystemCommand(&[_][]const u8{
        "llvm-objdump",  kernel_obj,
        "--disassemble", "--demangle",
        "--section",     ".text",
        "--section",     ".rodata",
        "--section",     ".got",
    });
    run_objdump.step.dependOn(&kernel.step);

    const objdump = b.step("objdump", "Dump the kernel ELF");
    objdump.dependOn(&run_objdump.step);
    var run_qemu_args = std.ArrayList([]const u8).init(b.allocator);
    try run_qemu_args.appendSlice(&[_][]const u8{
        "qemu-system-aarch64",
        "-kernel",
        kernel_name,
        "-M",
        "raspi3b",
        "-serial",
        "stdio",
        "-display",
        if (want_nodisplay) "none" else "cocoa",
        "-no-reboot",
    });
    if (want_asm) {
        try run_qemu_args.appendSlice(&[_][]const u8{
            "-d", "in_asm",
        });
    }
    if (want_monitor) {
        try run_qemu_args.appendSlice(&[_][]const u8{
            "-monitor", "tcp::7777",
        });
    }
    if (want_gdb) {
        try run_qemu_args.appendSlice(&[_][]const u8{
            "-s",
            "-S",
        });
    }
    const run_qemu = b.addSystemCommand(run_qemu_args.toOwnedSlice());
    run_qemu.step.dependOn(&run_objcopy.step);

    const qemu = b.step("qemu", "Run the program in qemu");
    qemu.dependOn(&run_qemu.step);
}
