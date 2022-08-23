.PHONY: clean, run

all: bootloader.bin

run: bootloader.bin
	qemu-system-i386 bootloader.bin

bootloader.bin: bootloader.asm
	nasm bootloader.asm -f bin -o bootloader.bin

clean:
	rm *.bin
