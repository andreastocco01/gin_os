; ah -> BIOS read sector function (0x02)
; al -> numero di settori da leggere
; es:bx -> indirizzo di destinazione in memoria
; ch -> cilindro
; cl -> settore nel cilindro specificato
; dh -> 0 faccia superiore, 1 faccia inferiore del disco
; dl -> disco da cui voglio fare la lettura
; int 0x13 leggo il disco specificato

disk_load:
    push dx
    push cx
    push bx
    push ax

    int 0x13 ; leggo il settore specificato dai parametri della funzione

    ; controllo che non ci siano stati errori

    jc disk_error ; esegue il salto solo se il carry flag e' settato. dopo la chiamata a int 0x13 viene settato per segnalare un guasto generale

    pop dx ; metto dentro a dx il valore precedente di ax. ora dentro a dl c'e' il numero di settori da leggere

    cmp al, dl ; alla fine della lettura 'al' viene settato al numero di settori letti. se e' diverso dal numero di settori richiesti c'e' un errore 
    jne disk_error

    ; ripristino il contenuto dei registri
    mov ax, dx
    pop bx
    pop cx
    pop dx
    ret

disk_error:
    mov bx, disk_error_message
    call print_string_rm
    jmp $


disk_error_message db 'Disk read error!', 0