[bits 64]
global load_idt
extern idt_pointer

load_idt:
    lidt[idt_pointer]
    ret
