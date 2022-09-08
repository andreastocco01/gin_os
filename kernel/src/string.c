#include "../lib/string.h"

uint32_t strlen(char* str) {
    uint32_t length = 0;
    while(*str != 0) {
        str++;
        length++;
    }
    return length;
}

void strcopy(char* to, char* from) {
    while(*from != 0) {
        *(to++) = *(from++);
    }
}