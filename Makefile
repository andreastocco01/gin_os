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

out/kernel.bin: out/kernel.elf
	objcopy -O binary $< $@

out/kernel.elf: out/kernel_entry.o out/main.o out/print.o out/math.o out/string.o
	ld -m elf_i386 -Ttext 0x1000 $^ -o $@

out/kernel_entry.o: boot/kernel_entry.asm
	nasm $< -felf -o $@

out/main.o: kernel/src/main.c
	gcc -m32 -ffreestanding -c $< -o $@

out/print.o: kernel/src/print.c
	gcc -m32 -ffreestanding -c $< -o $@

out/string.o: kernel/src/string.c
	gcc -m32 -ffreestanding -c $< -o $@

out/math.o: kernel/src/math.c
	gcc -m32 -ffreestanding -c $< -o $@

clean:
	rm out/*