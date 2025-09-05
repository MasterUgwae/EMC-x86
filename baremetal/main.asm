BITS 16                     ; Instruct NASM to produce 16 bit (real mode) code
org 0x7c00                  ; Set the origin to 0x7c00 which is where BIOS loads the bootloader

start:
    mov ax, 0xb800          ; Video memory segment (0xb800)
    mov es, ax              ; Load ES with the video memory segment

    xor di, di              ; Start of memory segment (using di as an offset)
    mov cx, 2000            ; 80 by 25 chars

clearscreen:
    mov byte [es:di], 0x20  ; Write space to video memory at ES:DI
    inc di

    mov byte [es:di], 0x07  ; Write attribute (light gray on black) to video memory at ES:DI
    inc di

    dec cx
    jnz clearscreen         ; Repeat if cx is non-zero

    lea si, [message]       ; Load the address of 'message' into SI
    xor di, di              ; Start at the beginning of the video memory (offset 0)
    mov cx, message_len

print_line:
    mov byte al, [si]       ; Move byte from message into the video memory
    mov byte [es:di], al

    dec cx
    jz halt

    inc si
    add di, 2

    jmp print_line

halt:
    cli                     ; Disable interrupts
    hlt                     ; Halt (Only resumes on an interrupt however they were disabled)

message db 'Hello world'
message_len equ $ - message

; Boot sector padding and signature
times 510-($-$$) db 0       ; Pad the boot sector to 510 bytes (ensuring the total size is 512 bytes)
dw 0xAA55                   ; Boot sector signature (0xAA55), required for a valid bootable sector
