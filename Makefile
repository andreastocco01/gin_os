.PHONY: clean, run, link

all: out/os.bin

run: out/os.bin
	qemu-system-i386 out/os.bin

out/os.bin: out/boot.bin out/kernel.bin
	cat out/boot.bin out/kernel.bin > out/os.bin

out/boot.bin: boot/boot.asm
	nasm boot/boot.asm -f bin -o out/boot.bin

out/kernel.bin: out/kernel_entry.o out/kernel.o out/print.o
	ld -m elf_i386 -o out/kernel.bin -Ttext 0x1000 out/kernel_entry.o out/kernel.o out/print.o --oformat binary

out/kernel_entry.o: boot/kernel_entry.asm
	nasm boot/kernel_entry.asm -felf -o out/kernel_entry.o

out/kernel.o: kernel/kernel.c
	gcc -m32 -ffreestanding -c kernel/kernel.c -o out/kernel.o

out/print.o: kernel/print.c
	gcc -m32 -ffreestanding -c kernel/print.c -o out/print.o

clean:
	rm out/*
