use core::{
    cell::UnsafeCell,
    fmt::Write,
    sync::atomic::{AtomicU8, AtomicUsize, Ordering},
};
pub struct TerminalWriterCell(pub UnsafeCell<TerminalWriter>);

unsafe impl Sync for TerminalWriterCell {}

pub static TERMINAL_WRITER: TerminalWriterCell =
    TerminalWriterCell(UnsafeCell::new(TerminalWriter::new()));

#[macro_export]
macro_rules! print {
    ($($args:tt)*) => { {

        #[allow(unused_unsafe)]
        unsafe {
         use $crate::vga::TerminalWriter;
         use core::fmt::Write as fmt_writer;
        let terminal_writer = &mut *($crate::vga::TERMINAL_WRITER.0.get());
        write!(terminal_writer, $($args)*).expect("failed to println");
        }
}};
}

#[macro_export]
macro_rules! println {
    ($($args: tt)*) => { {
        $crate::print!($($args)*);
        $crate::print!("\n");
    }
    }
}

#[allow(dead_code)]
enum VgaColor {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGrey = 7,
    DarkGrey = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
}

const fn vga_entry_color(fg: VgaColor, bg: VgaColor) -> u8 {
    fg as u8 | (bg as u8) << 4
}

const fn vga_entry(uc: u8, color: u8) -> u16 {
    uc as u16 | (color as u16) << 8
}

const VGA_WIDTH: usize = 80;
const VGA_HEIGHT: usize = 25;

pub struct TerminalWriter {
    terminal_pos: AtomicUsize,
    terminal_color: AtomicU8,
    terminal_buffer: *mut u16,
}

impl TerminalWriter {
    const fn new() -> TerminalWriter {
        let terminal_pos = AtomicUsize::new(0);
        let terminal_color = vga_entry_color(VgaColor::LightGrey, VgaColor::Black);
        let terminal_buffer = 0xb8000 as *mut u16;

        TerminalWriter {
            terminal_pos,
            terminal_color: AtomicU8::new(terminal_color),
            terminal_buffer,
        }
    }

    pub unsafe fn init() -> &'static TerminalWriter {
        let terminal_color = (*TERMINAL_WRITER.0.get())
            .terminal_color
            .load(Ordering::SeqCst);
        for y in 0..VGA_HEIGHT {
            for x in 0..VGA_WIDTH {
                let index = y * VGA_WIDTH + x;
                unsafe {
                    *(&*TERMINAL_WRITER.0.get()).terminal_buffer.add(index) =
                        vga_entry(b' ', terminal_color);
                }
            }
        }
        unsafe { &*(TERMINAL_WRITER.0.get()) }
    }

    #[allow(dead_code)]
    fn set_color(&mut self, color: u8) {
        self.terminal_color = AtomicU8::new(color);
    }

    // fn putentryat(&mut self, c: u8, color: u8, x: usize, y: usize) {
    //     let index = y * VGA_WIDTH + x;
    //     unsafe {
    //         *self.terminal_buffer.add(index) = vga_entry(c, color);
    //     }
    // }

    fn put_u32(&mut self, c: u32) {
        let mut num_digit = 1;
        loop {
            if c / 10_u32.pow(num_digit) == 0 {
                break;
            }

            num_digit += 1;
        }

        for i in (1..=num_digit).rev() {
            let c = (c / 10_u32.pow(i - 1)) % 10;
            self.putchar((c + 0x30) as u8);
        }
    }

    fn putchar(&self, c: u8) {
        if c == b'\n' {
            let mut terminal_pos = self.terminal_pos.load(Ordering::Acquire);
            terminal_pos += VGA_WIDTH - (terminal_pos % VGA_WIDTH);
            self.terminal_pos.store(terminal_pos, Ordering::Relaxed);
            return;
        }

        let color = self.terminal_color.load(Ordering::Relaxed);
        let pos = self.terminal_pos.fetch_add(1, Ordering::Relaxed);
        unsafe { *self.terminal_buffer.add(pos) = vga_entry(c, color) }
    }

    fn write(&self, data: &[u8]) {
        for c in data {
            self.putchar(*c);
        }
    }
}

impl Write for TerminalWriter {
    fn write_str(&mut self, s: &str) -> core::fmt::Result {
        self.write(s.as_bytes());
        Ok(())
    }
}
