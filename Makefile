.PHONY: clean, run

all: boot.bin

run: boot.bin
	qemu-system-i386 boot.bin

boot.bin: boot.asm
	nasm boot.asm -f bin -o boot.bin

clean:
	rm *.bin
