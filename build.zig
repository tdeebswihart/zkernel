const std = @import("std");
const Builder = std.build.Builder;

fn baremetal_target(exec: *std.build.LibExeObjStep, arch: std.builtin.Arch) void {
    var disabled_features = std.Target.Cpu.Feature.Set.empty;
    var enabled_feautres = std.Target.Cpu.Feature.Set.empty;

    switch(arch) {
        .x86_64 => {
            const features = std.Target.x86.Feature;
            disabled_features.addFeature(@enumToInt(features.mmx));
            disabled_features.addFeature(@enumToInt(features.sse));
            disabled_features.addFeature(@enumToInt(features.sse2));
            disabled_features.addFeature(@enumToInt(features.avx));
            disabled_features.addFeature(@enumToInt(features.avx2));

            enabled_feautres.addFeature(@enumToInt(features.soft_float));
            exec.code_model = .kernel;
        },
        .aarch64 => {
            const features = std.Target.aarch64.Feature;
            disabled_features.addFeature(@enumToInt(features.fp_armv8));
            disabled_features.addFeature(@enumToInt(features.crypto));
            disabled_features.addFeature(@enumToInt(features.neon));
            exec.code_model = .small;
        },
        else => unreachable,
    }

    exec.disable_stack_probing = true;
    exec.setTarget(.{
        .cpu_arch = arch,
        .os_tag = std.Target.Os.Tag.freestanding,
        .abi = std.Target.Abi.none,
        .cpu_features_sub = disabled_features,
        .cpu_features_add = enabled_feautres,
    });
}
pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const kernel = b.addExecutable("zkernel", "src/kmain.zig");
    baremetal_target(kernel, .x86_64);
    kernel.setLinkerScriptPath("linker.ld");
    kernel.setBuildMode(mode);
    kernel.install();

    b.default_step.dependOn(&kernel.step);
    // const run_cmd = exe.run();
    // run_cmd.step.dependOn(b.getInstallStep());
    // if (b.args) |args| {
        // run_cmd.addArgs(args);
    // }
//
    // const run_step = b.step("run", "Run the app");
    // run_step.dependOn(&run_cmd.step);
}
