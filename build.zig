const std = @import("std");
const Builder = std.build.Builder;

const boardChoice = enum {
    rpi3,
    rpi4,
};

pub fn build(b: *std.build.Builder) !void {
    const want_nodisplay = b.option(bool, "nodisplay", "No display for qemu") orelse false;
    const want_monitor = b.option(bool, "monitor", "Monitor chardev") orelse false;
    const want_gdb = b.option(bool, "gdb", "Wait for GDB connections on 1234") orelse false;
    const want_asm = b.option(bool, "disasm", "Dump asm as it is executed") orelse false;
    const board = b.option(boardChoice, "board", "Board to build for") orelse .rpi3;

    var disabled_features = std.Target.Cpu.Feature.Set.empty;
    var enabled_features = std.Target.Cpu.Feature.Set.empty;
    const features = std.Target.aarch64.Feature;
    disabled_features.addFeature(@enumToInt(features.fp_armv8));
    disabled_features.addFeature(@enumToInt(features.crypto));
    disabled_features.addFeature(@enumToInt(features.neon));

    const kernel_elf = b.addExecutable("kernel", "src/os.zig");
    kernel_elf.code_model = .small;

    kernel_elf.disable_stack_probing = true;
    kernel_elf.setTarget(.{
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
    var options = b.addOptions();
    options.addOption(boardChoice, "board", board);
    kernel_elf.addOptions("build_options", options);

    kernel_elf.setLinkerScriptPath(.{ .path = "src/bsp/raspberrypi/linker.ld" });
    kernel_elf.addAssemblyFile("src/platform/aarch64/boot.s");
    kernel_elf.setBuildMode(b.standardReleaseOptions());
    kernel_elf.setOutputDir("zig-cache");
    // Disabled until https://github.com/ziglang/zig/issues/10364 and/or https://github.com/ziglang/zig/issues/9844 are fixed
    kernel_elf.want_lto = false;
    kernel_elf.install();

    b.default_step.dependOn(&kernel_elf.step);
    const kernel_obj = kernel_elf.installRaw("kernel.img8", .{ .format = .bin });
    b.default_step.dependOn(&kernel_obj.step);

    const kernel_elf_path = b.fmt("{s}/{s}", .{ b.cache_root, kernel_elf.out_filename });
    const kernel_obj_path = b.getInstallPath(kernel_obj.dest_dir, kernel_obj.dest_filename);

    const run_objdump = b.addSystemCommand(&[_][]const u8{
        "llvm-objdump",  kernel_elf_path,
        "--disassemble", "--demangle",
        "--section",     ".text",
        "--section",     ".rodata",
        "--section",     ".got",
    });
    run_objdump.step.dependOn(&kernel_elf.step);
    b.step("objdump", "Dump the kernel ELF").dependOn(&run_objdump.step);

    const run_hopper = b.addSystemCommand(&[_][]const u8{
        "hopperv4", "-a", "-l", "ELF", "--aarch64", "-e", kernel_elf_path,
    });
    run_hopper.step.dependOn(&kernel_elf.step);
    b.step("disasm", "Disassemble kernel").dependOn(&run_hopper.step);

    const readelf = b.addSystemCommand(&[_][]const u8{
        "aarch64-elf-readelf", "--headers", kernel_elf_path,
    });
    readelf.step.dependOn(&kernel_elf.step);
    b.step("readelf", "Dump elf headers").dependOn(&readelf.step);

    const nm = b.addSystemCommand(&[_][]const u8{
        "aarch64-elf-nm", kernel_elf_path,
    });
    nm.step.dependOn(&kernel_elf.step);
    b.step("nm", "Dump symbol table").dependOn(&nm.step);

    var run_qemu_args = std.ArrayList([]const u8).init(b.allocator);
    try run_qemu_args.appendSlice(&[_][]const u8{
        "qemu-system-aarch64",
        "-kernel",
        kernel_obj_path,
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
    run_qemu.step.dependOn(&kernel_obj.step);

    const qemu = b.step("qemu", "Run the program in qemu");
    qemu.dependOn(&run_qemu.step);
}
