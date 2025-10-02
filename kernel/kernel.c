/// 64 bit kernel

#include <stdint.h>

void println(char* print);

void _start() {
    println("64-bit mode");

    while (1) {
        __asm__ volatile("hlt\n\t");
    }
}

void println(char* print) {
    static uint64_t line = 10;
    char volatile* vga = (char volatile*)(line * 160 + 0xb8000);
    while (*print != '\0') {
        *vga = *print;
        print++;
        vga += 2;
    }
    line++;
}
