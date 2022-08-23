[org 0x7c00] ; il BIOS carica il bootloader sempre all'indirizzo 0x7c00. di conseguenza e' necessario aggiungere questo offset ad ogni indirizzo
             ; per poter reperire la cella di memoria desiderata. questa istruzione dice al compilatore di aggiungere tale offset ad ogni indirizzo
             ; di memoria utilizzato, senza doverlo aggiungere manualmente ogni volta.

bits 16

main:
    mov [disk_num], dl ; il numero del disco da cui sto facendo il booting viene salvato nel registro dl.
                       ; voglio leggere altri dati da questo disco, salvo tale numero in memoria
    mov bx, msg
    call print_string
    ; call disk_load
    jmp $

%include "utils/print_string.asm"
; %include "utils/disk_load.asm"

msg db 'Started in 16 bit real mode', 0
disk_num db 0

times 510 - ($ - $$) db 0
dw 0xaa55

; times 512 db '.' ; riempio il settore successivo a quello di booting di '.'
