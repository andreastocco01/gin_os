#!/bin/bash

nasm -f bin boot.asm -o boot.bin
nasm -f elf64 loader.asm -o loader.o

#cc -m64  -ffreestanding -fno-builtin -nostdlib -c main.c
cc -m64 -masm=intel -c main.c
ld  -Ttext 0x100000 -o kernel.elf loader.o main.o 
objcopy -R .note -R .comment -S -O binary kernel.elf kernel.bin

dd if=/dev/zero of=image.bin bs=512 count=2880
dd if=boot.bin of=image.bin conv=notrunc
dd if=kernel.bin of=image.bin conv=notrunc bs=512 seek=1

rm ./boot.bin ./kernel.bin ./main.o ./loader.o ./kernel.elf

qemu-system-x86_64  image.bin