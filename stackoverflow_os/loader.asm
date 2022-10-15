 [bits 64]


;mov al, 'K'
;mov ah, 3 ; cyan
;mov edx, 0xb8000
;mov [edx], ax
;jmp $

extern main
global _start

_start:
  call main     ; Call our kernel's main() function
  hlt 