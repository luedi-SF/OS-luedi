[SECTION .text]
[BITS 32]
extern kernel_main

global _start
_start:
    xchg bx,bx ; bp
    call kernel_main

    jmp $


