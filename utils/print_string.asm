; bx: address of the string
print_string:
    pusha
    mov ah, 0x0e ; scrolling teletype BIOS routine

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
