disk_load:
    pusha
    mov ah, 0x02 ; BIOS read sector function
    mov al, 1 ; quanti settori voglio leggere
    mov ch, 0 ; cilindro: 0
    mov cl, 2 ; settore: 2 (nel settore 1 c'e' boot_sect.asm, il settore 2 l'ho riempito di 'A')
    mov dh, 0 ; head: 0 (sta ad indicare se voglio leggere la faccia superiore o inferiore del disco)
    mov dl, [disk_num] ; voglio leggere i dati dallo stesso disco da cui sto facendo il booting

    ; ora devo dire alla CPU dove salvare, in RAM, i dati letti. questi devono essere salvati in es:bx
    push ax
    mov ax, 0
    mov es, ax
    pop ax
    mov bx, 0x7e00 ; 0x7e00 = 0x7c00 (offset iniziale) + 512 (dimensione settore di booting)

    int 0x13 ; leggo il settore specificato

    ;controllo che non ci siano stati errori

    jc disk_error ; esegue il salto solo se il carry flag e' settato. dopo la chiamata a int 0x13 viene settato per segnalare un guasto generale

    cmp al, 1 ; alla fine della lettura 'al' viene settato al numero di settori letti. se e' diverso dal numero di settori richiesti c'e' un errore 
    jne disk_error
  
    ; stampo un carattere del settore letto
    mov ah, 0x0e
    mov al, [0x7e00]
    int 0x10

    popa
    ret

disk_error:
    mov bx, disk_error_message
    call print_string
    jmp $

disk_error_message db 'Disk read error!', 0