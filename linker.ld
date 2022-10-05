ENTRY (start)

SECTIONS {
    . = 0x2000;

    .text :
    {
        out/kernel_entry.o(.text)
        out/main.o(.text)
        *(.text)
    }
    
    .bss :
    {
        *(.bss)
    }
}