[bits 32]

video_memory equ 0xb8000                    ; inizio memoria video
white_on_black equ 0x0f

; bx: address of the string

print_string_pm:
    pusha
    mov edx, video_memory
    mov ah, white_on_black                  ; setto l'attributo del carattere

.loop:
    mov al, [ebx]                           ; copio il carattere da scrivere in al
    cmp al, 0
    je .done
    mov [edx], ax                           ; metto i carattere e il suo attributo nella cella corrente della memoria video
    inc ebx                                 ; mi sposto sul carattere successivo
    add edx, 2                              ; mi sposto sulla prossima cella della memoria video
    jmp .loop

.done:
    popa
    ret