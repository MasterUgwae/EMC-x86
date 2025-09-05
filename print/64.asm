section .data
    hello db 'Hello world', 0x0A ; Hello world followed by a newline
    ; $ is current mem location, then subtracts start of hello to get length
    length equ $ - hello ; Length of hello in bytes

section .text
    global _start ; Make _start accessible to the linker

_start:
    mov rax, 1 ; set syscall to 1 (sys_write)
    mov rdi, rax ; set arg1 to 1 (stdout)
    mov rsi, hello ; set arg2 to point to hello
    mov rdx, length ; set arg3 to length of hello
    syscall ; perform the syscall

    mov rax, 60 ; set syscall to 60 (exit)
    xor rdi, rdi ; set arg1 to 0 (success)
    syscall ; perform the syscall
