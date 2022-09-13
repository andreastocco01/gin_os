#include "../lib/string.h"

uint16_t strlen(char* str) {
    uint16_t length = 0;
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