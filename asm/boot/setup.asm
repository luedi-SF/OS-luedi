[ORG  0x500]
[SECTION .gdt]
[BITS 32]
CODE_SELECTOR equ (1 << 3) ; Index: 0000000000001 Ti: 0 RPL: 00
DATA_SELECTOR equ (2 << 3) ; Index: 0000000000010 Ti: 0 RPL: 00
; dd : 4 bytes
; dw : 2 bytes 16 bits
; db : 1 byte


gdt_base:
    dd 0,0 ; first 8 bytes must be 0.
gdt_code:
    dw 0xFFFF   ; Segment limit 0-15
    dw 0x0000   ; Base address  0-15
    db


[SECTION .text]
[BITS 32]
global _start
_start:
    ; 设置屏幕模式为文本模式，清除屏幕
    mov eax, 3
    int 0x10





    mov     si, msg_setup
    call    print


    mov     ax, 0
    mov     ss, ax
    mov     ds, ax
    mov     es, ax
    mov     fs, ax
    mov     gs, ax
    mov     si, ax

while:

    mov     si, msg1
    call    print
    call    sleep
    call    clear_screen

    mov     si, msg2
    call    print
    call    sleep
    call    clear_screen

    mov     si, msg3
    call    print
    call    sleep
    call    clear_screen

    jmp     while

; 如何调用
; mov     si, msg   ; 1 传入字符串
; call    print     ; 2 调用
print:
    mov ah, 0x0e
    mov bh, 0
    mov bl, 0x01
.loop:
    mov al, [si]
    cmp al, 0
    jz .done
    int 0x10

    inc si
    jmp .loop
.done:
    ret

clear_screen:
    mov ah,    0x06
    mov al,    0
    mov cx,    0
    mov dh,    24
    mov dl,    79
    mov bh,    0x07
    int        0x10
    ret




sleep:
    mov ah,86h
    mov cx,0x8
    mov dx,0x0
    int 15h
    ret

msg_setup:
    db "Setup", 10, 13, 0
msg1:
    db "hello, world.", 10, 13, 0
msg2:
    db "hello, world..", 10, 13, 0
msg3:
    db "hello, world...", 10, 13, 0
