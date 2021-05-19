const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *std.build.Builder) void {
    const want_nodisplay = b.option(bool, "nodisplay", "No display for qemu") orelse false;
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const kernel = b.addExecutable("kernel", "src/kmain.zig");

    var disabled_features = std.Target.Cpu.Feature.Set.empty;
    var enabled_feautres = std.Target.Cpu.Feature.Set.empty;

    const features = std.Target.aarch64.Feature;
    disabled_features.addFeature(@enumToInt(features.fp_armv8));
    disabled_features.addFeature(@enumToInt(features.crypto));
    disabled_features.addFeature(@enumToInt(features.neon));
    kernel.code_model = .small;

    kernel.disable_stack_probing = true;
    kernel.setTarget(.{
        .cpu_arch = .aarch64,
        .cpu_model = .{.explicit = &std.Target.aarch64.cpu.cortex_a72},
        .os_tag = std.Target.Os.Tag.freestanding,
        .abi = std.Target.Abi.none,
        .cpu_features_sub = disabled_features,
        .cpu_features_add = enabled_feautres,
    });

    kernel.setLinkerScriptPath("src/bsp/raspberrypi/linker.ld");
    kernel.setBuildMode(mode);
    kernel.setOutputDir("zig-cache");
    kernel.install();

    b.default_step.dependOn(&kernel.step);
    const kernel_name = "kernel8.img";

    const run_objcopy = b.addSystemCommand(&[_][]const u8{
        "llvm-objcopy", kernel.getOutputPath(),
        "--only-section", ".text",
        "-O",           "binary",
        kernel_name,
    });
    run_objcopy.step.dependOn(&kernel.step);

    b.default_step.dependOn(&run_objcopy.step);

    const run_qemu = b.addSystemCommand(&[_][]const u8{
        "qemu-system-aarch64",
        "-d",
        "in_asm",
        "-kernel",
        kernel_name,
        //"-m",
        //"256",
        "-M",
        "raspi3",
        "-serial",
        "stdio",
        "-display",
        if (want_nodisplay) "none" else "cocoa",
    });
    run_qemu.step.dependOn(&run_objcopy.step);

    const qemu = b.step("qemu", "Run the program in qemu");
    qemu.dependOn(&run_qemu.step);
}
