pub fn eret() noreturn {
    asm volatile ("eret");
}
