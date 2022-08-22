.PHONY: clean, run

all: boot_sect.bin

run: boot_sect.bin
	qemu-system-i386 boot_sect.bin

boot_sect.bin: boot_sect.asm
	nasm boot_sect.asm -f bin -o boot_sect.bin

clean:
	rm boot_sect.bin
