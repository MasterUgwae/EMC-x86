section .data
    hello db 'Hello world', 0x0A
    length equ $ - hello

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, hello
    mov edx, length
    int 80h

    mov eax, ebx
    xor ebx, ebx
    int 80h
