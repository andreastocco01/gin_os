[bits 16]

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
    je .disabled
    mov bx, msg_enabled_A20
    call print_string_rm

.done:
    pop cx
    pop ax
    ret

.disabled:
    mov bx, msg_disabled_A20
    call print_string_rm
    jmp .done

msg_enabled_A20 db 'A20 line is enabled', 0xa, 0xd, 0x0
msg_disabled_A20 db 'A20 line is disabled', 0xa, 0xd, 0x0