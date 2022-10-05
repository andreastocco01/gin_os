[org 0x7c00]                                    ; il BIOS carica il bootloader sempre all'indirizzo 0x7c00. di conseguenza e'
                                                ; necessario aggiungere questo offset ad ogni indirizzo
                                                ; per poter reperire la cella di memoria desiderata. questa istruzione dice al 
                                                ; compilatore di aggiungere tale offset ad ogni indirizzo
                                                ; di memoria utilizzato, senza doverlo aggiungere manualmente ogni volta.

[bits 16]

start:
    mov [disk_num], dl ; il numero del disco da cui sto facendo il booting viene salvato nel registro dl.
                       ; voglio leggere altri dati da questo disco, salvo tale numero in memoria
    mov bp, 0x9000     ; posiziono lo stack in un indirizzo sicuro
    mov sp, bp

    mov bx, msg_real_mode
    call print_string_rm

    mov bx, msg_loading_second_stage
    call print_string_rm

    ; carico secondo bootloader in memoria.
    mov al, 2                       ; numero di settori da leggere dal disco
    mov bx, second_boot_position    ; indirizzo di destinazione in memoria
    mov ch, 0                       ; cilindro 0, lo stesso del bootloader
    mov cl, 2                       ; nel settore 1 c'e' il primo bootloader, devo leggere da quello successivo per prelevare il secondo
    mov dh, 0                       ; leggo la faccia superiore del disco
    mov dl, [disk_num]              ; leggo dallo stesso disco in cui e' presente il bootloader
    call disk_load

    mov bx, msg_done
    call print_string_rm

    mov dl, [disk_num]
    jmp second_boot_position

    

msg_real_mode db 'Started in 16 bit real mode', 0xa, 0xd, 0x0
msg_loading_second_stage db 'Loading second stage bootloader...', 0x0
msg_done db 'Done', 0xa, 0xd, 0x0
disk_num db 0
second_boot_position equ 0x1000

%include "boot/print_string_rm.asm"
%include "boot/disk_load.asm"

times 510 - ($ - $$) db 0
dw 0xaa55