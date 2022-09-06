# $@ = target file
# $< = first dependency
# $^ = all dependencies

.PHONY: clean, run

all: run

run: out/os.bin
	qemu-system-i386 $<

out/os.bin: out/boot.bin out/kernel.bin
	cat $^ > $@

out/boot.bin: boot/boot.asm
	nasm $< -f bin -o $@

out/kernel.bin: out/kernel_entry.o out/kernel.o out/print.o
	ld -m elf_i386 -o $@ -Ttext 0x1000 $^ --oformat binary

out/kernel_entry.o: boot/kernel_entry.asm
	nasm $< -felf -o $@

out/kernel.o: kernel/kernel.c
	gcc -m32 -ffreestanding -c $< -o $@

out/print.o: kernel/src/print.c
	gcc -m32 -ffreestanding -c $< -o $@

clean:
	rm out/*