const std = @import("std");
pub const BoardChoice = enum {
    rpi3,
    rpi4,
};

const KernelOpts = struct {
    name: []const u8,
    path: []const u8,
    target: std.zig.CrossTarget,
    build_options: *std.build.OptionsStep,
};

const Kernel = struct {
    elf: *std.build.LibExeObjStep,
    elf_path: []const u8,
    obj: *std.build.InstallRawStep,
    obj_path: []const u8,
};

var libk = std.build.Pkg{ .name = "libk", .source = .{
    .path = "lib/libk.zig",
} };

fn mkKernel(b: *std.build.Builder, opts: KernelOpts) Kernel {
    const elf = b.addExecutable(opts.name, opts.path);
    elf.addPackage(libk);
    elf.code_model = .small;

    elf.disable_stack_probing = true;
    elf.setTarget(opts.target);
    elf.addOptions("build_options", opts.build_options);
    // todo: this sucks but oh well
    elf.setLinkerScriptPath(.{ .path = "lib/bsp/raspberrypi/linker.ld" });
    elf.addAssemblyFile("lib/platform/aarch64/boot.s");
    elf.setBuildMode(b.standardReleaseOptions());
    elf.setOutputDir("zig-cache");
    // Disabled until https://github.com/ziglang/zig/issues/10364 and/or https://github.com/ziglang/zig/issues/9844 are fixed
    elf.want_lto = false;
    elf.install();

    const obj = elf.installRaw(b.fmt("{s}.img8", .{opts.name}), .{ .format = .bin });
    obj.step.dependOn(&elf.step);

    return .{
        .elf = elf,
        .elf_path = b.fmt("{s}/{s}", .{ b.cache_root, elf.out_filename }),
        .obj = obj,
        .obj_path = b.getInstallPath(obj.dest_dir, obj.dest_filename),
    };
}

const TestOpts = struct {
    name: []const u8,
    display: bool = false,
    debug: bool = false,
    // Kernel config
    target: std.zig.CrossTarget,
    build_options: *std.build.OptionsStep,
};

fn mkTest(b: *std.build.Builder, parent: *std.build.Step, opts: TestOpts) !void {
    const test_kern = mkKernel(b, .{
        .name = opts.name,
        .path = b.fmt("src/tests/{s}.zig", .{opts.name}),
        .target = opts.target,
        .build_options = opts.build_options,
    });
    var run_args = std.ArrayList([]const u8).init(b.allocator);
    try run_args.appendSlice(&[_][]const u8{
        "qemu-system-aarch64",
        "-kernel",
        test_kern.obj_path,
        "-M",
        "raspi3b",
        "-semihosting",
        "-serial",
        "stdio",
        "-display",
        if (opts.display) "cocoa" else "none",
        "-no-reboot",
    });
    if (opts.debug) {
        try run_args.appendSlice(&[_][]const u8{
            "-s",
            "-S",
        });
    }
    const run_qemu = b.addSystemCommand(run_args.toOwnedSlice());
    run_qemu.step.dependOn(&test_kern.obj.step);
    parent.dependOn(&run_qemu.step);
}

pub fn build(b: *std.build.Builder) !void {
    const want_nodisplay = b.option(bool, "nodisplay", "No display for qemu") orelse false;
    const want_monitor = b.option(bool, "monitor", "Monitor chardev") orelse false;
    const want_gdb = b.option(bool, "gdb", "Wait for GDB connections on 1234") orelse false;
    const want_asm = b.option(bool, "disasm", "Dump asm as it is executed") orelse false;
    const board = b.option(BoardChoice, "board", "Board to build for") orelse .rpi3;
    var options = b.addOptions();
    options.addOption(BoardChoice, "board", board);

    libk.dependencies = &[_]std.build.Pkg{options.getPackage("build_options")};

    var disabled_features = std.Target.Cpu.Feature.Set.empty;
    var enabled_features = std.Target.Cpu.Feature.Set.empty;
    const features = std.Target.aarch64.Feature;
    disabled_features.addFeature(@enumToInt(features.fp_armv8));
    disabled_features.addFeature(@enumToInt(features.crypto));
    disabled_features.addFeature(@enumToInt(features.neon));
    const x_target: std.zig.CrossTarget = .{
        .cpu_arch = .aarch64,
        .cpu_model = .{ .explicit = switch (board) {
            .rpi3 => &std.Target.aarch64.cpu.cortex_a53,
            .rpi4 => &std.Target.aarch64.cpu.cortex_a72,
        } },
        .os_tag = std.Target.Os.Tag.freestanding,
        .abi = std.Target.Abi.none,
        .cpu_features_sub = disabled_features,
        .cpu_features_add = enabled_features,
    };

    // testing
    var tests = b.step("qemu-tests", "Run kernel tests in QEMU");
    b.default_step.dependOn(tests);
    try mkTest(b, tests, .{
        .name = "test_boot",
        .debug = want_gdb,
        .target = x_target,
        .build_options = options,
    });

    // main kernel
    const kernel = mkKernel(b, .{
        .name = "kernel",
        .path = "src/os.zig",
        .target = x_target,
        .build_options = options,
    });

    // Introspection for the kernel
    const run_objdump = b.addSystemCommand(&[_][]const u8{
        "llvm-objdump",  kernel.elf_path,
        "--disassemble", "--demangle",
        "--section",     ".text",
        "--section",     ".rodata",
        "--section",     ".got",
    });
    run_objdump.step.dependOn(&kernel.elf.step);
    b.step("objdump", "Dump the kernel ELF").dependOn(&run_objdump.step);

    const run_hopper = b.addSystemCommand(&[_][]const u8{
        "hopperv4", "-a", "-l", "ELF", "--aarch64", "-e", kernel.elf_path,
    });
    run_hopper.step.dependOn(&kernel.elf.step);
    b.step("disasm", "Disassemble kernel").dependOn(&run_hopper.step);

    const readelf = b.addSystemCommand(&[_][]const u8{
        "aarch64-elf-readelf", "--headers", kernel.elf_path,
    });
    readelf.step.dependOn(&kernel.elf.step);
    b.step("readelf", "Dump elf headers").dependOn(&readelf.step);

    const nm = b.addSystemCommand(&[_][]const u8{
        "aarch64-elf-nm", kernel.elf_path,
    });
    nm.step.dependOn(&kernel.elf.step);
    b.step("nm", "Dump symbol table").dependOn(&nm.step);

    var run_qemu_args = std.ArrayList([]const u8).init(b.allocator);
    try run_qemu_args.appendSlice(&[_][]const u8{
        "qemu-system-aarch64",
        "-kernel",
        kernel.obj_path,
        "-M",
        "raspi3b",
        "-semihosting",
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
    run_qemu.step.dependOn(&kernel.obj.step);

    const qemu = b.step("qemu", "Run the program in qemu");
    qemu.dependOn(&run_qemu.step);
}
