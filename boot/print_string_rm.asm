[bits 16]

; bx: address of the string
print_string_rm:
    pusha
    mov ah, 0xe ; scrolling teletype BIOS routine

.loop:
    mov al, [bx]
    cmp al, 0
    je .done
    int 0x10 ; stampa il carattere in al
    add bx, 1
    jmp .loop

.done:
    popa
    ret