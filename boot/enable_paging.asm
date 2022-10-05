[bits 32]

enable_paging:
    ; move page table address to cr3

    mov eax, p4_table
    mov cr3, eax

    ; enable PAE

    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; set the long mode bit

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; enable paging
    
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ret
