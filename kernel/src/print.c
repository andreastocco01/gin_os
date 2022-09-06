#include "../lib/print.h"

uint8_t* vga_index = (uint8_t*) vga_address;

void clear_vga() {
    for(int i = 0; i < 80 * 25; i++) {
        *vga_index = 0x20;
        vga_index += 2;
    }
    vga_index = (uint8_t*) vga_address;
}

void setup_vga() {
    vga_index++;
    for(int i = 0; i < 80 * 25; i++) {
        *vga_index = vga_color;
        vga_index += 2;
    }
    vga_index = (uint8_t*) vga_address;
}

int str_length(char* str) {
    int length = 0;
    while(*str != 0) {
        str++;
        length++;
    }
    return length;
}

void print_string(char* str) {
    int length = str_length(str);
    for(int i = 0; i < length; i++) {
        *vga_index = *str;
        vga_index += 2;
        str++;
    }
}