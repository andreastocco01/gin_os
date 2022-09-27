[bits 32]

; se si riesce a flippare il 21esimo bit del registro flags, allora l'istruzione cpuid e' disponibile
check_cpuid:
    pushfd
    pop eax             ; sposto il contenuto di flags dentro ad eax tramite stack

    mov ecx, eax        ; salvo il contenuto di flags dentro ecx prima di effettuare il flip
    xor eax, 1 << 21    ; flip del 21esimo bit

    push eax
    popfd               ; cambio il contenuto di flags attraverso lo stack

    pushfd
    pop eax             ; rimetto dentro ad eax il nuovo contenuto di flags (con il 21esimo it cambiato se cpuid e' supportato)

    push ecx
    popfd               ; risetto flags allo stato iniziale via stack

    cmp eax, ecx
    je .no_cpuid
    ret

.no_cpuid:
    jmp $
