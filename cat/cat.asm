; Cli args (stack)
; Syscalls: open, fstat, mmap, write, munmap, close, exit

section .bss
    stat_buffer resb stat_buffer_len ; size of the struct stat

section .data
    arg_error_text db 'Must be given a single argument', 0x0A
    arg_error_len equ $ - arg_error_text
    open_error_text db 'Failed to open file', 0x0A
    open_error_len equ $ - open_error_text
    fstat_error_text db 'Failed to call fstat', 0x0A
    fstat_error_len equ $ - fstat_error_text
    mmap_error_text db 'Failed to call mmap', 0x0A
    mmap_error_len equ $ - mmap_error_text
    stat_buffer_len equ 144

section .text
    global _start

_start:
    cmp qword [rsp], 2 ; [rsp] contains no. of args
    jne arg_exit
    mov rdi, [rsp+16] ; [rsp+8] contains ptr to path arg, [rsp+16] contains first arg

    ; open file, filename already in rdi, rdx is garbage as O_CREAT is not set
    xor rsi, rsi ; 0 for O_RDONLY (read only)
    mov rax, 2
    syscall
    cmp rax, 0
    jl open_exit ; exit if fd is negative (error)

    ; call fstat
    mov rdi, rax ; fd
    mov rsi, stat_buffer
    mov rax, 5
    syscall
    cmp rax, 0
    jne fstat_exit ; exit if an error is returned

    mov r8, rdi ; fd
    ; move size of file into rsi and round it up to a multiple of page size (4KiB)
    mov qword rsi, [stat_buffer+48]
    add rsi, 4096
    mov rax, 0xFFF ; Load mask
    not rax ; Not mask (all 1s but the 1s less than 4096)
    and rsi, rax
    mov r12, rsi ; store in r12 so its not overwritten

    ; Allocate memory contained by fd
    xor rdi, rdi ; NULL for any starting address
    mov rdx, 1 ; PROT_READ (prot)
    mov r10, 2 ; MAP_PRIVATE (flags)
    xor r9, r9 ; 0 offset
    mov rax, 9
    syscall
    cmp rax, 0
    jl mmap_exit ; exit if an error is returned

    mov rsi, rax ; ptr to address
    mov rdx, [stat_buffer+48]
    mov rdi, 1 ; stdout
    mov rax, rdi
    syscall ; print buffer

    ; munmap buffer (not required as we exit anyway)
    mov rdi, rsi
    mov rsi, r12
    mov rax, 11
    syscall ; Ignore potential error since we exit anyway

    ; close file (not required as we exit anyway)
    mov rdi, r8
    mov rax, 3 ; line could be removed, the fd is likely 3 as its the lowest unused fd
    syscall ; Ignore potential error since we exit anyway

    ; exit
    xor rdi, rdi
    mov rax, 60
    syscall

mmap_exit:
    mov rsi, mmap_error_text
    mov rdx, mmap_error_len
    jmp exit
fstat_exit:
    mov rsi, fstat_error_text
    mov rdx, fstat_error_len
    jmp exit
open_exit:
    mov rsi, open_error_text
    mov rdx, open_error_len
    jmp exit
arg_exit:
    mov rsi, arg_error_text
    mov rdx, arg_error_len
exit: ; rsi - ptr, rdx - len
    ; print to stderr
    mov rdi, 2
    mov rax, 1
    syscall
    ; exit
    mov rdi, 1
    mov rax, 60
    syscall
