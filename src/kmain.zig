const std = @import("std");
//const arch = @import("arch/aarch64/cpu.zig");

comptime {
    asm (
        // SPDX-License-Identifier: MIT OR Apache-2.0
        //
        // Copyright (c) 2021 Andre Richter <andre.o.richter@gmail.com>

        //--------------------------------------------------------------------------------------------------
        // Public Code
        //--------------------------------------------------------------------------------------------------
        \\.section .text._start

        //------------------------------------------------------------------------------
        // fn _start()
        //------------------------------------------------------------------------------
        \\ _start:
        // Infinitely wait for events (aka "park the core").
        \\  1: wfe
        \\     b  1b

        \\.size	_start, . - _start
        \\.type	_start, function
        \\.global	_start
    );
}

pub fn kmain() noreturn {
    unreachable_;
}
