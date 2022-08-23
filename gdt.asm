gdt_start:

null_descriptor:
    dd 0x0
    dd 0x0

code_descriptor:
    dw 0xffff    ; Limit (bits 0...15)
    dw 0x0000    ; Base (bits 16...31)
    db 0x00      ; Base (bits 32...39)
    db 10011010b ; Access Byte (Present: 1, Privilege: 00, Descriptor: 1, Code: 1, Conforming: 0, Readable: 1, Accessed: 0)
    db 11001111b ; Flags (Granularity: 1, 32-bit default: 1, 64 bit seg: 0, AVL:0), Limit (bits 48...51)
    db 0x00      ; Base (bits 56...63)

data_descriptor:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10010010b ; Access Byte (Present: 1, Privilege: 00, Descriptor: 1, Code: 0, Conforming: 0, Readable: 1, Accessed: 0)
    db 11001111b ; Flags (Granularity: 1, 32-bit default: 1, 64 bit seg: 0, AVL:0), Limit (bits 48...51)
    db 0x00 

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; dimensione della tabella
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start