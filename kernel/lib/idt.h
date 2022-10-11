#include <stdint.h>

typedef struct {
    uint16_t lower_offset;
    uint16_t selector;
    uint8_t ist;
    uint8_t attributes;
    uint16_t midder_offset;
    uint32_t upper_offset;
    uint32_t zero;
} __attribute__((packed)) IdtEntry;

typedef struct {
    uint64_t* base;
    uint16_t limit; // number of byte of the IDT
} __attribute__((packed)) IdtPointer;