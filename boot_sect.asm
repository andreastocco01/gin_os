[org 0x7c00] ; il BIOS carica il bootloader sempre all'indirizzo 0x7c00. di conseguenza e' necessario aggiungere questo offset ad ogni indirizzo
             ; per poter reperire la cella di memoria desiderata. questa istruzione dice al compilatore di aggiungere tale offset ad ogni indirizzo
             ; di memoria utilizzato, senza doverlo aggiungere manualmente ogni volta.

bits 16

main:
  mov bx, msg
  call print_string
  mov [diskNum], dl ; il numero del disco da cui sto facendo il booting viene salvato nel registro dl. voglio leggere altri dati da questo disco, 
                    ; salvo tale numero in memoria
  call read_from_disk
  jmp $

print_string:
  pusha
  mov ah, 0x0e ; scrolling teletype BIOS routine

.loop:
  mov al, [bx]
  cmp al, 0
  je .done
  int 0x10 ; stampa il carattere in al
  add bx, 1
  jmp .loop

.done:
  popa
  ret

read_from_disk:
  pusha
  mov ah, 0x02 ; BIOS read sector function
  mov al, 1 ; quanti settori voglio leggere
  mov ch, 0 ; cilindro: 0
  mov cl, 2 ; settore: 2 (nel settore 1 c'e' boot_sect.asm, il settore 2 l'ho riempito di 'A')
  mov dh, 0 ; head: 0 (sta ad indicare se voglio leggere la faccia superiore o inferiore del disco)
  mov dl, [diskNum] ; voglio leggere i dati dallo stesso disco da cui sto facendo il booting

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

msg db 'Booting OS', 0
disk_error_message db 'Disk read error!', 0
diskNum db 0

times 510 - ($ - $$) db 0
dw 0xaa55

times 512 db 'A' ; riempio il settore successivo a quello di booting di 'A'
