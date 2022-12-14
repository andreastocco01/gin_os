# $@ = target file
# $< = first dependency
# $^ = all dependencies

.PHONY: clean, run, debug

CC = gcc
LD = ld
CFLAGS = -ffreestanding -m64 -nostdlib -fno-stack-protector
LDFLAGS = -T linker.ld

all: out/os.bin

run: out/os.bin
	qemu-system-x86_64 $<

debug: out/os.bin
	qemu-system-x86_64 $< -S -s

out/os.bin: out/first_stage.bin out/second_stage.bin out/kernel.bin
	cat $^ > $@

out/first_stage.bin: bootloader/first_stage.asm
	nasm $< -f bin -o $@

out/second_stage.bin: bootloader/second_stage.asm
	nasm $< -f bin -o $@

out/kernel.bin: out/kernel.elf
	objcopy -O binary $< $@

out/kernel.elf: out/kernel_entry.o out/main.o out/print.o out/math.o out/string.o out/load_idt.o
	$(LD) $(LDFLAGS) $^ -o $@

out/kernel_entry.o: bootloader/kernel_entry.asm
	nasm $< -felf64 -o $@

out/load_idt.o: kernel/src/load_idt.asm
	nasm $< -felf64 -o $@

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
