#include <stdint.h>
#include "../lib/string.h"
#include "../lib/print.h"
#include "../lib/idt.h"

extern void load_idt();
IdtPointer idt_pointer;

int main() {
    setup_vga();
    clear_vga();
    printf("Start execution of kernel code\n");
    printf("Creation of IDT...");
    IdtEntry idt[256]; // l'idt deve avere 256 entry.
    memset(idt, 0, sizeof(IdtEntry) * 256); // ogni byte della tabella viene inizializzata a 0
    IdtPointer idt_pointer;
    idt_pointer.base = (uint64_t*) &idt;
    idt_pointer.limit = (sizeof(IdtEntry) * 256) - 1;
    load_idt();
    printf("Done\n");
    return 0;
}