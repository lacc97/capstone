const std = @import("std");

const Build = std.Build;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const capstone_lib = b.addStaticLibrary(.{
        .name = "capstone",
        .target = target,
        .optimize = optimize,
    });
    switch (optimize) {
        .Debug => capstone_lib.defineCMacro("CAPSTONE_DEBUG", null),
        .ReleaseSmall => {
            capstone_lib.defineCMacro("CAPSTONE_DIET", null);
            capstone_lib.defineCMacro("NDEBUG", null);
        },
        else => capstone_lib.defineCMacro("NDEBUG", null),
    }
    capstone_lib.addIncludePath(.{ .path = "include" });
    addArchitectureSources(b, capstone_lib);
    capstone_lib.addCSourceFiles(&base_sources, &base_flags);
    capstone_lib.linkLibC();
    b.installArtifact(capstone_lib);
}

const base_sources = [_][]const u8{
    "cs.c",
    "Mapping.c",
    "MCInst.c",
    "MCInstrDesc.c",
    "MCRegisterInfo.c",
    "SStream.c",
    "utils.c",
};
const base_flags = [_][]const u8{
    "-std=c99",
    "-Wmissing-braces",
    "-Wunused-function",
    "-Warray-bounds",
    "-Wunused-variable",
    "-Wparentheses",
    "-Wint-in-bool-context",
};

const ArchitectureOption = struct {
    name: []const u8,
    sources: []const []const u8,
};
fn addArchitectureSources(b: *Build, compile: *Build.Step.Compile) void {
    const archs = [_]ArchitectureOption{
        .{
            .name = "ARM",
            .sources = &.{
                "arch/ARM/ARMDisassembler.c",
                "arch/ARM/ARMInstPrinter.c",
                "arch/ARM/ARMMapping.c",
                "arch/ARM/ARMModule.c",
            },
        },
        .{
            .name = "ARM64",
            .sources = &.{
                "arch/AArch64/AArch64BaseInfo.c",
                "arch/AArch64/AArch64Disassembler.c",
                "arch/AArch64/AArch64InstPrinter.c",
                "arch/AArch64/AArch64Mapping.c",
                "arch/AArch64/AArch64Module.c",
            },
        },
        .{
            .name = "M68K",
            .sources = &.{
                "arch/M68K/M68KDisassembler.c",
                "arch/M68K/M68KInstPrinter.c",
                "arch/M68K/M68KModule.c",
            },
        },
        .{
            .name = "MIPS",
            .sources = &.{
                "arch/Mips/MipsDisassembler.c",
                "arch/Mips/MipsInstPrinter.c",
                "arch/Mips/MipsMapping.c",
                "arch/Mips/MipsModule.c",
            },
        },
        .{
            .name = "PowerPC",
            .sources = &.{
                "arch/PowerPC/PPCDisassembler.c",
                "arch/PowerPC/PPCInstPrinter.c",
                "arch/PowerPC/PPCMapping.c",
                "arch/PowerPC/PPCModule.c",
            },
        },
        .{
            .name = "Sparc",
            .sources = &.{
                "arch/Sparc/SparcDisassembler.c",
                "arch/Sparc/SparcInstPrinter.c",
                "arch/Sparc/SparcMapping.c",
                "arch/Sparc/SparcModule.c",
            },
        },
        .{
            .name = "SystemZ",
            .sources = &.{
                "arch/SystemZ/SystemZDisassembler.c",
                "arch/SystemZ/SystemZInstPrinter.c",
                "arch/SystemZ/SystemZMapping.c",
                "arch/SystemZ/SystemZModule.c",
                "arch/SystemZ/SystemZMCTargetDesc.c",
            },
        },
        .{
            .name = "XCore",
            .sources = &.{
                "arch/XCore/XCoreDisassembler.c",
                "arch/XCore/XCoreInstPrinter.c",
                "arch/XCore/XCoreMapping.c",
                "arch/XCore/XCoreModule.c",
            },
        },
        .{
            .name = "x86",
            .sources = &.{
                "arch/X86/X86Disassembler.c",
                "arch/X86/X86DisassemblerDecoder.c",
                "arch/X86/X86IntelInstPrinter.c",
                "arch/X86/X86InstPrinterCommon.c",
                "arch/X86/X86Mapping.c",
                "arch/X86/X86Module.c",
            },
        },
        .{
            .name = "TMS320C64x",
            .sources = &.{
                "arch/TMS320C64x/TMS320C64xDisassembler.c",
                "arch/TMS320C64x/TMS320C64xInstPrinter.c",
                "arch/TMS320C64x/TMS320C64xMapping.c",
                "arch/TMS320C64x/TMS320C64xModule.c",
            },
        },
        .{
            .name = "M680x",
            .sources = &.{
                "arch/M680X/M680XDisassembler.c",
                "arch/M680X/M680XInstPrinter.c",
                "arch/M680X/M680XModule.c",
            },
        },
        .{
            .name = "EVM",
            .sources = &.{
                "arch/EVM/EVMDisassembler.c",
                "arch/EVM/EVMInstPrinter.c",
                "arch/EVM/EVMMapping.c",
                "arch/EVM/EVMModule.c",
            },
        },
        .{
            .name = "MOS65XX",
            .sources = &.{
                "arch/MOS65XX/MOS65XXModule.c",
                "arch/MOS65XX/MOS65XXDisassembler.c",
            },
        },
        .{
            .name = "WASM",
            .sources = &.{
                "arch/WASM/WASMDisassembler.c",
                "arch/WASM/WASMInstPrinter.c",
                "arch/WASM/WASMMapping.c",
                "arch/WASM/WASMModule.c",
            },
        },
        .{
            .name = "BPF",
            .sources = &.{
                "arch/BPF/BPFDisassembler.c",
                "arch/BPF/BPFInstPrinter.c",
                "arch/BPF/BPFMapping.c",
                "arch/BPF/BPFModule.c",
            },
        },
        .{
            .name = "RISCV",
            .sources = &.{
                "arch/RISCV/RISCVDisassembler.c",
                "arch/RISCV/RISCVInstPrinter.c",
                "arch/RISCV/RISCVMapping.c",
                "arch/RISCV/RISCVModule.c",
            },
        },
        .{
            .name = "SH",
            .sources = &.{
                "arch/SH/SHDisassembler.c",
                "arch/SH/SHInstPrinter.c",
                "arch/SH/SHModule.c",
            },
        },
        .{
            .name = "TriCore",
            .sources = &.{
                "arch/TriCore/TriCoreDisassembler.c",
                "arch/TriCore/TriCoreInstPrinter.c",
                "arch/TriCore/TriCoreMapping.c",
                "arch/TriCore/TriCoreModule.c",
            },
        },
    };

    @setEvalBranchQuota(10000);
    inline for (archs) |arch| {
        const option_name = comptime blk: {
            const orig = "no_" ++ arch.name;
            var buf: [orig.len]u8 = undefined;
            break :blk std.ascii.upperString(&buf, orig);
        };
        const disable = b.option(
            bool,
            option_name,
            "Disable support for " ++ arch.name ++ " architecture",
        ) orelse false;

        if (!disable) {
            const definition = comptime blk: {
                const orig = "capstone_has_" ++ arch.name;
                var buf: [orig.len]u8 = undefined;
                break :blk std.ascii.upperString(&buf, orig);
            };
            compile.defineCMacro(definition, null);
            compile.addCSourceFiles(arch.sources, &base_flags);
        }
    }
}
