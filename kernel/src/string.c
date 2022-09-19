#include "../lib/string.h"

uint32_t strlen(char* str) {
    uint32_t length = 0;
    while(*str != 0) {
        str++;
        length++;
    }
    return length;
}

void strcpy(char* to, const char* from) {
    while(*from != 0) {
        *(to++) = *(from++);
    }
}

void* memset(void* ptr, int value, uint32_t num) {
    while(num > 0) {
        *((int*)ptr++) = value;
        num--;
    }
    return ptr;
}