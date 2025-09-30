#pragma once

#include <stdint.h>

struct struct_page {
    /// Linear = Physical
    uint64_t physical_base;
};

void paging_create(struct struct_page* page);
