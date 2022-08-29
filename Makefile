.PHONY: clean, run, link

all: link

run: os.bin
	qemu-system-i386 os.bin

link: boot.bin kernel.bin
	cat boot.bin kernel.bin > os.bin

boot.bin: boot.asm
	nasm boot.asm -f bin -o boot.bin

kernel.bin: kernel_entry.o kernel.o
	ld -m elf_i386 -o kernel.bin -Ttext 0x1000 kernel_entry.o kernel.o --oformat binary

kernel_entry.o: kernel_entry.asm
	nasm kernel_entry.asm -felf -o kernel_entry.o

kernel.o: kernel.c
	gcc -m32 -ffreestanding -c kernel.c -o kernel.o

clean:
	rm *.bin *.o
