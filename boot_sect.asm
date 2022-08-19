[org 0x7c00] ; il BIOS carica il bootloader sempre all'indirizzo 0x7c00. di conseguenza e' necessario aggiungere questo offset ad ogni indirizzo
             ; per poter reperire la cella di memoria desiderata. questa istruzione dice al compilatore di aggiungere tale offset ad ogni indirizzo
             ; di memoria utilizzato, senza doverlo aggiungere manualmente ogni volta.

bits 16

main:
  mov bx, msg
  call print_string
  jmp $

print_string:
  pusha
  mov ah, 0x0e
.loop:
  mov al, [bx]
  int 0x10 ; stampo il carattere in al
  add bx, 1
  mov cx, [bx]
  cmp cx, 0
  jne .loop
  popa
  ret

msg db 'Booting OS', 0

times 510 - ($ - $$) db 0
dw 0xaa55
