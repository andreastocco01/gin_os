[org 0x7c00] ; il BIOS carica il bootloader sempre all'indirizzo 0x7c00. di conseguenza e' necessario aggiungere questo offset ad ogni indirizzo
             ; per poter reperire la cella di memoria desiderata. questa istruzione dice al compilatore di aggiungere tale offset ad ogni indirizzo
             ; di memoria utilizzato, senza doverlo aggiungere manualmente ogni volta.

[bits 16]

start_real_mode:
    mov [disk_num], dl ; il numero del disco da cui sto facendo il booting viene salvato nel registro dl.
                       ; voglio leggere altri dati da questo disco, salvo tale numero in memoria
    mov bp, 0x9000     ; posiziono lo stack in un indirizzo sicuro
    mov sp, bp

    mov bx, msg_real_mode
    call print_string_rm

    mov bx, msg_loading_kernel
    call print_string_rm
    
    ; carico il kernel in memoria. lo faccio adesso perche' in protected mode non ho le chiamate al BIOS
    mov al, 25              ; numero di settori da leggere dal disco
    mov bx, kernel_position ; indirizzo di destinazione in memoria
    mov ch, 0               ; cilindro 0, lo stesso del bootloader
    mov cl, 2               ; nel settore 1 c'e' il bootloader, devo leggere da quello successivo per prelevare il kernel
    mov dh, 0               ; leggo la faccia superiore del disco
    mov dl, [disk_num]      ; leggo dallo stesso disco in cui e' presente il bootloader
    call disk_load

    mov bx, msg_done
    call print_string_rm

    ; preparo lo switch in protected mode

    call enable_A20 ; A20 line dovrebbe essere abilitata da qemu automaticamente, per sicurezza la riabilito
    call check_A20
    cli ; disabilito gli interrupt
    lgdt [gdt_descriptor] ; carico la GDT
    
    ; effettuo lo switch
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    jmp CODE_SEG:start_protected_mode ; CODE_SEG parte da 0 ed e' grande come tutta la memoria, quindi sarebbe uguale fare jmp start_protected_mode
                                      ; metto anche il segmento perche' cosi' obbligo la CPU a fare un far jump e quindi a svuotare la pipeline
                                      ; con il far jump, cs viene automaticamente aggiornato a CODE_SEG

; uso le funzioni del BIOS per abilitare la A20 line.
; ponendo ax = 0x2400, 0x2401, 0x2402 e chiamando successivamente int 15 si riesce a disabilitare, abilitare o controllare lo stato (attiva, non attiva) 
; dell' A20 line.
;
; Return status of the commands 2400 and 2401(Disabling,Enabling)
; CF = clear if success
; AH = 0
; CF = set on error
; AH = status (01=keyboard controller is in secure mode, 0x86=function not supported)
;
; Return Status of the command 2402
; CF = clear if success
; AH = status (01: keyboard controller is in secure mode; 0x86: function not supported)
; AL = current state (00: disabled, 01: enabled)
; CX = set to 0xffff is keyboard controller is no ready in 0xc000 read attempts
; CF = set on error

enable_A20:
    push ax
    mov ax, 0x2401
    int 0x15
    pop ax
    ret

check_A20:
    push ax
    push cx
    mov ax, 0x2402
    int 0x15
    cmp al, 00
    je disabled
    mov bx, msg_enabled_A20
    call print_string_rm

.done:
    pop cx
    pop ax
    ret

disabled:
    mov bx, msg_disabled_A20
    call print_string_rm
    jmp check_A20.done

%include "boot/print_string.asm"
%include "boot/disk_load.asm"
%include "boot/gdt.asm"
%include "boot/disable_cursor.asm"
%include "boot/check_cpuid.asm"
%include "boot/check_long_mode.asm"

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

    call disable_cursor ; non usero' piu' il cursore della scrolling teletype BIOS routine, lo disabilito.

    mov ebp, 0x90000
    mov esp, ebp

    mov ebx, msg_protected_mode
    call print_string_pm

    ; preparo lo switch in long mode
    call check_cpuid
    call check_long_mode

    jmp kernel_position ; salto all'indirizzo 0x1000 che, quando verra' eseguito il codice, conterra' la prima istruzione di kernel_entry.
                        ; questo perche' con il linker metto il codice di kernel_entry sopra a quello di kernel.
                        ; da kernel_entry posso decidere il punto di ingresso del kernel, che non deve essere per forza la prima istruzione

msg_real_mode db 'Started in 16 bit real mode', 0xa, 0xd, 0x0
msg_protected_mode db 'Switched in 32 bit protected mode', 0x0
msg_loading_kernel db 'Loading kernel in memory...', 0x0
msg_done db 'Done', 0xa, 0xd, 0x0
msg_enabled_A20 db 'A20 line is enabled', 0xa, 0xd, 0x0
msg_disabled_A20 db 'A20 line is disabled', 0xa, 0xd, 0x0
disk_num db 0
kernel_position equ 0x1000

times 510 - ($ - $$) db 0
dw 0xaa55