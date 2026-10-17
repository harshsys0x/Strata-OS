# #!/usr/bin/env bash
# set -Eeuo pipefail
# set -x

# # Always run from the directory containing this script.
# cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

# # Cross-compiler locations.
# CROSS_ROOT_WSL="/mnt/d/osdev/opt/cross"
# CROSS_BIN="$CROSS_ROOT_WSL/bin"
# CROSS_ROOT_WIN="D:/osdev/opt/cross"
# GCC_VERSION="16.2.0"

# AS="$CROSS_BIN/i686-elf-as.exe"
# GCC="$CROSS_BIN/i686-elf-gcc.exe"
# LD="$CROSS_BIN/i686-elf-ld.exe"

# # GRUB tools must be installed inside Ubuntu/WSL.
# for tool in grub-file grub-mkrescue xorriso; do
#     if ! command -v "$tool" >/dev/null 2>&1; then
#         echo "Missing $tool. Install GRUB tools and xorriso first." >&2
#         exit 1
#     fi
# done

# # Remove an old ISO so a failed build cannot leave a stale ISO
# # that looks like the latest build succeeded.
# rm -f myos.iso

# # 1. Assemble the bootloader.
# "$AS" boot.s -o boot.o

# # 2. Compile C into assembly.
# # -B tells GCC where its internal compiler program cc1.exe lives.
# # -isystem specifies the GCC headers we found earlier.
# # -S stops at assembly generation, avoiding GCC's wrong assembler selection.
# "$GCC" \
#     -B"${CROSS_ROOT_WIN}/libexec/gcc/i686-elf/${GCC_VERSION}/" \
#     -isystem "${CROSS_ROOT_WIN}/lib/gcc/i686-elf/${GCC_VERSION}/include" \
#     -std=gnu99 \
#     -ffreestanding \
#     -fno-pic -fno-pie \
#     -O2 -Wall -Wextra \
#     -S kernel.c -o kernel.s

# # 3. Assemble the generated C assembly using our cross-assembler.
# "$AS" kernel.s -o kernel.o

# # 4. Find libgcc, which supplies compiler helper routines when needed.
# LIBGCC_WSL="$(find "$CROSS_ROOT_WSL" -type f -name libgcc.a -print -quit)"

# if [[ -n "$LIBGCC_WSL" ]]; then
#     LIBGCC_DIR_WIN="$(wslpath -m "$(dirname "$LIBGCC_WSL")")"

#     "$LD" -m elf_i386 \
#         -T linker.ld \
#         -o myos.bin \
#         boot.o kernel.o \
#         -L"$LIBGCC_DIR_WIN" -lgcc
# else
#     echo "WARNING: libgcc.a not found; trying to link without it." >&2

#     "$LD" -m elf_i386 \
#         -T linker.ld \
#         -o myos.bin \
#         boot.o kernel.o
# fi

# # 5. Check that GRUB recognizes the kernel's Multiboot header.
# if ! grub-file --is-x86-multiboot myos.bin; then
#     echo "ERROR: GRUB does not recognize myos.bin as a Multiboot kernel." >&2
#     exit 1
# fi

# echo "Multiboot kernel check passed."

# # 6. Build the ISO directory.
# rm -r isodir
# mkdir -p isodir/boot/grub

# cp myos.bin isodir/boot/myos.bin
# cp grub.cfg isodir/boot/grub/grub.cfg

# # 7. Create the bootable ISO using GRUB.
# grub-mkrescue -o myos.iso isodir

# echo "Build successful: myos.iso"


set -ex

cargo +nightly build -Zjson-target-spec --verbose

rm -fr isodir

mkdir -p isodir/boot/grub

cp target/target/debug/kernel isodir/boot/myos.bin

cp grub.cfg isodir/boot/grub/grub.cfg

grub-mkrescue -o myos.iso isodir


ISO_WIN=$(wslpath -w /mnt/d/Strata-OS/myos.iso)

/mnt/d/Qemu/qemu-system-i386.exe -cdrom "$ISO_WIN"