#[unsafe(no_mangle)]
pub unsafe extern "C" fn memset(s: *mut u8, c: i32, n: usize) -> *mut u8 {
    let bytes = s;
    //let c = c as u8;
    for i in 0..n {
        unsafe {
            *bytes.add(i) = c as u8;
        }
    }
    s
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn memcpy(d: *mut u8, s: *mut u8, n: usize) -> *mut u8 {
    for i in 0..n {
        unsafe {
            *d.add(i) = *s.add(i);
        }
    }

    d
}
