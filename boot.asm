[org 0x7c00] ; il BIOS carica il bootloader sempre all'indirizzo 0x7c00. di conseguenza e' necessario aggiungere questo offset ad ogni indirizzo
             ; per poter reperire la cella di memoria desiderata. questa istruzione dice al compilatore di aggiungere tale offset ad ogni indirizzo
             ; di memoria utilizzato, senza doverlo aggiungere manualmente ogni volta.

[bits 16]

start:
    mov [disk_num], dl ; il numero del disco da cui sto facendo il booting viene salvato nel registro dl.
                       ; voglio leggere altri dati da questo disco, salvo tale numero in memoria
    mov bp, 0x9000 ; posiziono lo stack in un indirizzo sicuro
    mov sp, bp

    mov bx, msg_real_mode
    call print_string_rm
    ; call disk_load

    ; effettuo lo switch in protected mode

    cli ; disabilito gli interrupt
    lgdt [gdt_descriptor] ; carico la GDT
    
    ; effettuo lo switch vero e proprio
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    jmp CODE_SEG:start_protected_mode ; CODE_SEG parte da 0 ed e' grande come tutta la memoria, quindi sarebbe uguale fare jmp start_protected_mode
                                      ; metto anche il segmento perche' cosi' obbligo la CPU a fare un far jump e quindi a svuotare la pipeline
                                      ; con il far jump, cs viene automaticamente aggiornato a CODE_SEG

%include "utils/print_string.asm"
%include "gdt.asm"
; %include "utils/disk_load.asm"

[bits 32]

start_protected_mode:

    ; per entrare in 32 bit protected mode ho abilitato la segmentazione (anche se i segmenti definiti sono completamente inutili)
    ; ora dovrei associare a ciascun segment register il rispettivo selettore nella GDT. Ora, essendoci solo due segmenti sovrapposti
    ; la segmentazione e' "fake" e quindi basta settare tutti i segment register al DATA_SEG (o al CODE_SEG) perche' tanto la
    ; segmentazione non e' realmente implementata (in 16 bit il contenuto di tutti questi registri era 0, infatti non c'era
    ; la segmentazione)
    mov ax, DATA_SEG 
    mov ds, ax
    mov ss, ax
    mov es, ax ; extra segment
    mov fs, ax ; general purpose
    mov gs, ax ; general purpose

    mov ebp, 0x90000
    mov esp, ebp

    mov ebx, msg_protected_mode
    call print_string_pm
    jmp $


msg_real_mode db 'Started in 16 bit real mode', 0
msg_protected_mode db 'Switched in 32 bit protected mode', 0
disk_num db 0

times 510 - ($ - $$) db 0
dw 0xaa55

; times 512 db '.' ; riempio il settore successivo a quello di booting di '.'
