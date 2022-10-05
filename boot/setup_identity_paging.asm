[bits 32]

section .bss

align 4096                                  ; in questo modo tutte le page table si trovano ad indirizzi multipli di 4096

p4_table:                                   ; page map level four table
    resb 4096

p3_table:                                   ; page directory pointer table
    resb 4096

p2_table:                                   ; page directory table
    resb 4096

section .text

setup_identity_paging:
    mov eax, p3_table                      ; salvo in eax l'indirizzo della prima entry di pdp table
    or eax, 11b                             ; in questo modo setto i primi due bit dell' indirizzo contenuto in eax ad 1 (present, writable bits)
                                            ; ogni entry all'interno di una page table e' un indirizzo. avendo allineato tutte le page
                                            ; table a 4096 i primi 12 bit (2 ^ 12 = 4096) vengono ignorati dalla cpu.
                                            ; di conseguenza posso utilizzarli come metadata senza cambiare l'indirizzo.
    
    mov dword [p4_table + 0], eax             ; la prima entry di pml4 table punta alla prima entry di pdp table

    mov eax, p2_table
    or eax, 11b
    mov dword [p3_table + 0], eax              ; la prima entry di pdp table punta alla prima entry di pd table

    ; adesso devo far si che le entry di pd_table puntino effettivamente a delle page table.
    ; la prima entry deve puntare ad una page table che parte dall' indirizzo 0
    ; la seconda deve puntare ad una che parte da 2MB...

    mov ecx, 0

.map_p2_table:
    mov eax, 0x200000                       ; 2MB
    mul ecx                                 ; eax = eax * ecx
    or eax, 10000011b                       ; setto a 1, oltre che present e writable, anche huge bit
                                            ; (indica che la dimensione delle pagine non e' 4Kb ma 2MB)

    mov [p2_table + ecx * 8], eax           ; salvo la nuova entry
    inc ecx
    cmp ecx, 512                            ; ogni tabella ha 512 entry
    jne .map_p2_table

    ret