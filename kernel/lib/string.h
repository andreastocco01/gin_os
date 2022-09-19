#ifndef STRING_H
#define STRING_H

#include <stdint.h>

uint32_t strlen(char* str);
void strcpy(char* to, const char* from);
void* memset(void * ptr, int value, uint32_t num);

#endif