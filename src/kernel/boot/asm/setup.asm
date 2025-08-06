;###################
;### SETUP
;### This file aims to detect hardware, obtain specific contents, enter protected mode, and load the kernel.
;### Located in the second sector of the disk.
;### It's a 16-bit.
;###################
[ORG  0x500]
[SECTION .data]
[BITS 16]
KERNAL_PTR equ 0x1000
[SECTION .gdt]
CODE_SELECTOR equ (1 << 3) ; Index: 0000000000001 Ti: 0 RPL: 00
DATA_SELECTOR equ (2 << 3) ; Index: 0000000000010 Ti: 0 RPL: 00
; dd : 4 bytes
; dw : 2 bytes 16 bits
; db : 1 byte

gdt_base:
    dd 0,0 ; first 8 bytes must be 0.
gdt_code:
    ;GDT Descriptor Information:
    ;- BASE (0x00000000): Linear address where the segment begins
    ;- LIMIT (0xFFFFF): Maximum addressable unit in bytes
    ;  Actual segment size: 1.00 MB
    ;- DB (1): Default operation size - 32-bit protected mode
    ;- DPL (00): Privilege level - Ring 0 (Highest privilege, kernel mode)
    ;- G (0): Scaling factor - Byte granularity
    ;- P (1): Presence flag - Segment is present in memory
    ;- S (1): Descriptor defines a code or data segment
    ;- TYPE -- 11:(1),10:(0),9:(0),8:(0)
    ;- TYPE (0001): Access permissions - Code segment: Not accessed, Execute-only, Non-conforming
    ;- L (0): Not a 64-bit code segment
    ;- AVL (0): Available for system use (no defined function)
    ;('0000ffff', '004f9800')
;    dd 0xffff0000,0x0089f400
    dd 0x0000ffff, 0x004f9800
gdt_data:
    ;GDT Descriptor Information:
    ;- BASE (0x00000000): Linear address where the segment begins
    ;- LIMIT (0xFFFFF): Maximum addressable unit in 4KB pages
    ;  Actual segment size: 4096.00 MB
    ;- DB (1): Default operation size - 32-bit protected mode
    ;- DPL (00): Privilege level - Ring 0 (Highest privilege, kernel mode)
    ;- G (1): Scaling factor - 4KB granularity
    ;- P (1): Presence flag - Segment is present in memory
    ;- S (1): Descriptor defines a code or data segment
    ;- TYPE -- 11:(0),10:(1),9:(0),8:(0)
    ;- TYPE (0010): Access permissions - Data segment: Not accessed, Read-only, Expand-down (stack-like)
    ;- L (0): Not a 64-bit code segment
    ;- AVL (0): Available for system use (no defined function)
    ;('0000ffff', '00cf9400')
    dd 0x0000ffff,0x00cf9400
gdt_ptr:             ; 0x0000 00000000   totaly 6 bytes
    dw $ - gdt_base  ; the size of gdt 2bytes 0-1
    dd gdt_base      ; the location of gdt 4bytes 2-5

[SECTION .text]
_start:

    ; print info
    mov     si, msg_setup_pm
    call    print
;enter protected mode
protected_mode:
    ; disable interrupt
    cli
;end

    ; open A20
    in al, 0x92
    or al, 2
    out 0x92, al
;end

    ;set gdtr(gdt register)
    lgdt  [gdt_ptr]
;end

    ; set PE=0 in the cr0
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
;end

    ; read kernel file
    call read_kernal

;end
            ;    ;print
            ;    mov esi, msg_load_Kernel
            ;    call  CODE_SELECTOR:print
            ;
            ;    xchg bx,bx;bp
            ;;end
    ; jump to kernel
    jmp CODE_SELECTOR:KERNAL_PTR
;end


read_kernal:

    ; 0x1F2 : Sector Count : 100
    mov  dx,  0x1F2
    mov  al,  100
    out  dx,  al

    ; Begin : 0x0000003 (sector 3)
    ; 0x1F3 : LBA low : 3
    inc  dx
    mov  al,  3
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

    ; set destination : 0x1000
    mov  di,  KERNAL_PTR
    ; 0x1F7 send 0x20 to read command
    inc  dx;
    mov  al,  0x20
    out  dx,  al

    ; Read all 100 sectors
    mov  bx,  100  ; Number of sectors to read
.read_sector:
    ; check status (dx should be 0x1F7 - status register)
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

    ; Read one sector (256 words = 512 bytes)
    mov  dx,  0x1F0
    mov  ecx,  256
.read_words:
    in   ax,  dx
    mov [di], ax
    add  di,  2
    loop .read_words
    
    ; Move to next sector
    dec  bx
    mov  dx,  0x1F7  ; Restore status register for next iteration
    jnz  .read_sector

    ret

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


msg_setup_pm:
    db "Setup Protected mode", 10, 13, 0

