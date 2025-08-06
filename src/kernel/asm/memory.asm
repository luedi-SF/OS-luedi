; author : luedi
; date : 2023-08-06

[bits 32]
[SECTION .text]

global memcopy
memcopy:
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov edi, [ebp + 8]     ; dest
    mov esi, [ebp + 12]    ; src
    mov ecx, [ebp + 16]    ; size
    cld
    rep movsb
    
    mov eax, [ebp + 8]     ; return dest pointer
    
    pop edi
    pop esi
    pop ebp
    ret