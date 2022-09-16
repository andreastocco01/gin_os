# $@ = target file
# $< = first dependency
# $^ = all dependencies

.PHONY: clean, run

CC = gcc
LD = ld
CFLAGS = -ffreestanding -m32 -nostdlib -fno-stack-protector
LDFLAGS = -m elf_i386 -Ttext 0x1000

all: run

run: out/os.bin
	qemu-system-i386 $<

out/os.bin: out/boot.bin out/kernel.bin
	cat $^ > $@

out/boot.bin: boot/boot.asm
	nasm $< -f bin -o $@

out/kernel.bin: out/kernel.elf
	objcopy -O binary $< $@

out/kernel.elf: out/kernel_entry.o out/main.o out/print.o out/math.o out/string.o
	$(LD) $(LDFLAGS) $^ -o $@

out/kernel_entry.o: boot/kernel_entry.asm
	nasm $< -felf -o $@

out/main.o: kernel/src/main.c
	$(CC) $(CFLAGS) -c $< -o $@

out/print.o: kernel/src/print.c
	$(CC) $(CFLAGS) -c $< -o $@

out/string.o: kernel/src/string.c
	$(CC) $(CFLAGS) -c $< -o $@

out/math.o: kernel/src/math.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm out/*
