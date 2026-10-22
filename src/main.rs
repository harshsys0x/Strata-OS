#![allow(bad_asm_style)]
#![no_std]
#![no_main]

#[macro_use]
mod vga;
mod libc;
mod multiboot;

use core::arch::global_asm;
use core::cell::UnsafeCell;
use core::ffi::c_void;
use core::num;
use core::panic::PanicInfo;
use multiboot::*;
use vga::TerminalWriter;
global_asm!(include_str!("../boot.s"));

#[unsafe(no_mangle)]
pub extern "C" fn kernel_main(_multiboot_magic: u32, info: *const MultiBootInfo) -> i32 {
    unsafe {
        TerminalWriter::init();
        print_mmap_sections(info);
        print!("hey hey");
    }
    0
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
