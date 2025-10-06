/// 64 bit kernel

#include <stdint.h>
#include "../include/shared_constants.h"
#include "../include/utils.h"

void _start() {
    println("64-bit mode");

    for (uint64_t i = 0; i < 24; i++) {
        println(u64_to_string(1 << i));
    }

    while (1) {
        __asm__ volatile("hlt\n\t");
    }
}
