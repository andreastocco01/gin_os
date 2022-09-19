#include <stdint.h>

typedef struct {
    uint16_t lower_offset;
    uint16_t selector;
    uint8_t reserved; // unused, set to 0
    uint8_t attributes;
    uint16_t upper_offset;
} __attribute__((packed)) IdtEntry;

typedef struct {
    uint32_t* base;
    uint16_t limit; // number of byte of the IDT
} __attribute__((packed)) IdtPointer;