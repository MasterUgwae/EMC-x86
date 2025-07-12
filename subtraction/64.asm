section .bss
    print_buffer_len equ 128
    print_buffer resb print_buffer_len ; Reserve bytes of uninitilised memory

section .data
    prompt_text db 'Enter two values to find their difference', 0x0A
    prompt_len equ $ - prompt_text 

section .text
    global _start

_start:
    ; print prompt text
    mov rax, 1
    mov rdi, rax
    mov rsi, prompt_text
    mov rdx, prompt_len
    syscall

    call read_rax
    mov rbx, rax
    call read_rax
    cmp rax, rbx
    jae skip_exchange
    xchg rax, rbx
skip_exchange:
    sub rax, rbx

    call print_rax
exit:
    xor rdi, rdi
    mov rax, 60
    syscall

; returns rax (value read)
read_rax:
    push rdi
    push rsi
    push rbx
    push rcx
    push rdx

    xor rax, rax
    xor rdi, rdi
    mov rsi, print_buffer
    mov rdx, print_buffer_len
    syscall

    ; Exit if returned value is greater than the buffer length
    cmp rax, print_buffer_len
    ja exit

    mov rcx, rax
    xor rax, rax
    mov rdi, 10
    xor rbx, rbx
read_loop:
    ; Exit if reached end of buffer and no newline
    dec rcx
    jc exit

    mov byte bl, [rsi]
    cmp rbx, 0x0A
    je read_return ; return if newline

    sub rbx, 48
    cmp rbx, 9
    ja exit ; exit if above 9 (so rbx is between 0 and 9 inclusive)

    mul rdi
    add rax, rbx
    inc rsi
    jmp read_loop

read_return:
    pop rdx
    pop rcx
    pop rbx
    pop rsi
    pop rdi
    ret

print_rax:
    push rdi
    push rsi
    push rdx
    push rbx
    push rax

    mov rsi, print_buffer
    xor rdi, rdi
    mov rbx, 10
print_loop_right:
    inc rdi
    xor rdx, rdx
    div rbx
    cmp rax, 0
    jne print_loop_right
    ; rsi now points to the location where the newline character should be
    add rsi, rdi
    mov byte [rsi], 0x0A

    ; read rax again
    mov rax, [rsp]
    inc rdi ; rdi now stores len of string
print_loop_left:
    dec rsi
    xor rdx, rdx
    div rbx
    add rdx, 48
    mov byte [rsi], dl
    cmp rax, 0
    jne print_loop_left

    mov rdx, rdi
    mov rax, 1
    mov rdi, rax
    syscall

    pop rax
    pop rbx
    pop rdx
    pop rsi
    pop rdi

    ret
