[bits 32]

check_long_mode:
    mov eax, 0x80000000                     ; argomento implicito per cpuid
    cpuid                                   ; ritorna in eax il piu' alto valore accettabile come parametro per cpuid
    cmp eax, 0x80000001
    jb .no_long_mode                        ; se e' minore di 0x80000001, la long mode non e' supportata

    ; si puo' quindi effettuare il test vero e proprio

    mov eax, 0x80000001
    cpuid                                   ; ritorna in ecx e edx un po' di informazioni utili sulla cpu
    test edx, 1 << 29                       ; se e' settato il 29esimo bit allora e' possibile passare in long mode
    jz .no_long_mode
    ret

.no_long_mode:
    jmp $