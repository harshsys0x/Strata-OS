
#[repr(C, packed)]
pub struct MultiBootInfo {
    pub flags: u32,
    pub mem_lower: u32,
    pub mem_upper: u32,
    pub boot_device: u32,
    pub cmdline: u32,
    pub mods_count: u32,
    pub mods_addr: u32,
    pub dummy: [u8; 16],

    pub mmap_length: u32,
    pub mmap_addr: u32,

    pub drives_length: u32,
    pub drives_addr: u32,

    pub config_table: u32,
    pub boot_loader_name: *const u8,

    pub apm_table: u32,
}

#[repr(C, packed)]
pub struct MultibootMmapEntry {
    pub size: u32,
    pub addr_low: u32,
    pub addr_high: u32,
    pub len_low: u32,
    pub len_hig: u32,
    pub typ: u32,
}

pub unsafe fn print_mmap_sections(info: *const MultiBootInfo) {
    let mmap_length = (*info).mmap_length;
    println!("Available memory segments...");
    println!("mmap_length: {mmap_length}");
    for i in 0..(*info).mmap_length {
        let p = ((*info).mmap_addr + core::mem::size_of::<MultibootMmapEntry>() as u32 * i)
            as *const MultibootMmapEntry; 
        let len = (*p).len_low;
        let size = (*p).size;
        if size == 0 {
            break;
        }
        let addr = (*p).addr_low;
        println!("size: {size}, len: {len}, addr: {addr}");
    }
}