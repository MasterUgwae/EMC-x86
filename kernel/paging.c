// Assumes 512MiB (29 bits) physical memory can be paged
// First MiB is not written to since there is often BIOS/UEFI data in it
// Uses level 4 paging

#include <stdint.h>

const uint64_t FLAGS = 0b000000000011; // R/W, P

void create_pde(uint64_t* base) {
    uint64_t* pte_base = base + 512;
    for (uintptr_t i = 0; i < 256; i++) {
        *base = (uintptr_t)pte_base | FLAGS;
        base++;
        pte_base += 512;
    }

    // Set remaining entries to 0
    for (uintptr_t i = 0; i < 256; i++) {
        *base = 0;
        base++;
    }

    // Creates 256 * 512 Pages
    uint64_t dst = 0;
    for (uintptr_t i = 0; i < 512 * 256; i++) {
        *base = dst | 3;
        base++;
        dst += 1 << 12;
    }
}

/// Only allocate first PDPTE and return its base address
/// base must be aligned to 4KiB and in a low address (eg 1MiB)
/// (also used to create pdpte since it has the same structure)
uint64_t* create_plm4e(uint64_t* base) {
    // Zero all other entries (P flag is 0)
    for (uintptr_t i = 1; i < 512; i++) {
        base[i] = 0;
    }

    uint64_t* pdpte = base + 512;
    *base = (uint64_t)pdpte | FLAGS;
    return pdpte;
}

struct struct_page {
    /// Linear = Physical
    uint64_t physical_base;
};

void paging_create(struct struct_page* page) {
    uint64_t base = 1 << 20;
    page->physical_base = base;
    uint64_t* pdpte = create_plm4e((uint64_t*)base);
    uint64_t* pde = create_plm4e(pdpte);
    create_pde(pde);
}
