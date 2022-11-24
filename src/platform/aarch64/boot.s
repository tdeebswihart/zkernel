// Load the address of a symbol into a register, PC-relative.
//
// The symbol must lie within +/- 4 GiB of the Program Counter.
//
// # Resources
//
// - https://sourceware.org/binutils/docs-2.36/as/AArch64_002dRelocations.html
.macro ADR_REL register, symbol
  adrp \register, \symbol
  add  \register, \register, #:lo12:\symbol
.endm

// Load the address of a symbol into a register, absolute.
//
// # Resources
//
// - https://sourceware.org/binutils/docs-2.36/as/AArch64_002dRelocations.html
.macro ADR_ABS register, symbol
	movz	\register, #:abs_g2:\symbol
	movk	\register, #:abs_g1_nc:\symbol
	movk	\register, #:abs_g0_nc:\symbol
.endm

.equ _EL2, 0x8
.equ _EL1, 0x4
.equ _core_id_mask, 0b11

.section .text._start

_start:
  // Park unless we're running in EL2
  mrs	x0, CurrentEL
  cmp	x0, _EL2
  b.ne .L_parking_loop
  // park everything but the boot core
  mrs x1, MPIDR_EL1
  and x1, x1, _core_id_mask
  ldr x2, BOOT_CORE_ID // provided by bsp cpu setup
  cmp x1, x2
  b.ne .L_parking_loop

  // Initialize DRAM
  ADR_REL x0, __bss_start
  ADR_REL x1, __bss_end_exclusive

.L_bss_init_loop:
  cmp x0, x1
  b.eq .L_prepare_zig
  stp xzr, xzr, [x0], #16
  b .L_bss_init_loop

.L_prepare_zig:
  // Grab the EL1 stack pointer
  ADR_REL x0, __boot_core_stack_end_exclusive
  mov sp, x0

  // Set up the transition to EL1
  // This is done here as I've separated my kernel binaries
  // from the library crate itself so I can reuse code with
  // the chainloader, etc. It means that the kernel library
  // doesn't have access to the kernel main address, however.
  ldr x1, =kmain
  // msr ELR_EL2, x1

  b kinit

.L_parking_loop:
	wfe
	b	.L_parking_loop

.size	_start, . - _start
.type	_start, function
.global	_start
