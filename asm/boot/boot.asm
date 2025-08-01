[ORG  0x7c00]

[SECTION .data]
SETUP_PTR equ 0x500


[SECTION .text]
[BITS 16]
global _start
_start:


;    mov     ch, 0   ; 0 柱面 (Cylinder)
;    mov     dh, 0   ; 0 磁头 (head)
;    mov     cl, 2   ; 2 扇区 (section)
;    mov     bx, BOOT_PTR  ; 数据往哪读
;
;    mov     ah, 0x02    ; 读盘操作
;    mov     al, 1       ; 连续读几个扇区
;    mov     dl, 0       ; 驱动器编号
;
;    int     0x13

    ; print
    mov si, loading_setup
    call print

    xchg bx, bx ;magic BP

    call LBA_read

    ; print
    mov si, LBA_setup
    call print

    xchg bx, bx ;magic BP

    jmp SETUP_PTR



; LBA
LBA_read:
    xor  ax,  ax

    ; 0x1F2 : Sector Count : 1
    mov  dx,  0x1F2
    mov  al,  1
    out  dx,  al

    ; Begin : 0x0000001
    ; 0x1F3 : LBA low : 1
    inc  dx
    mov  al,  1
    out  dx,  al

    ; 0x1F4 : LBA mid : 0
    inc  dx
    mov  al,  0
    out  dx,  al

    ; 0x1F5 : LBA high : 0
    inc  dx
    mov  al,  0
    out  dx,  al
    ; 0x1F6 : Primary disk
    inc  dx;     LBA  DRV LBA_high+
    mov  al,  0b1_1_1_0_0000
    out  dx,  al

    ; set destination : 0x500
    mov  di,  SETUP_PTR
    ; 0x1F7 send 0x20 to read command
    inc  dx;
    mov  al,  0x20
    out  dx,  al

    ; clean cx
    xor  ecx,  ecx
    ; set loop time : 256
    mov  cx,  256
    ; check status
    ; waiting BSY=0
.wait_not_busy:
    in   al,  dx
    test al,  0x80
    jnz  .wait_not_busy
    ; wait DRQ=1
.wait_drq:
    in   al,  dx
    test al,  0x08
    jz   .wait_drq

    ; read 0x1F0
    mov  dx,  0x1F0
.read_LBA:
    in   ax,  dx
    mov [di], ax
    add  di,  2
    loop .read_LBA

    ret




; mov   si, msg
; call  print
print:
    xor ax, ax
    xor bx, bx

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

loading_setup:
    db "Boot Setup ...", 10, 13, 0
LBA_setup:
    db "LBA Setup ...", 10, 13, 0

times 510 - ($ - $$) db 0
db 0x55, 0xaa