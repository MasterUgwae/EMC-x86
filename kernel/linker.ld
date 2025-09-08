/* OUTPUT_FORMAT(binary) */
/* SECTIONS { */
/*     . = 0x1000;  // Start address */
/*     .text : { */
/*         *(.text) */
/*     } */
/*     .data : { */
/*         *(.data) */
/*     } */
/*     .bss : { */
/*         *(.bss) */
/*     } */
/* } */

OUTPUT_FORMAT(binary)
SECTIONS {
    . = 0x7C00;
    .boot : { *(.boot) } /* Real mode code */
    . = 0x100000;
    .text : { *(.text) } /* Protected/long mode code */
    .data : { *(.data) }
    .bss  : { *(.bss) }
}
