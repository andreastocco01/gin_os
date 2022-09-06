#include "../lib/print.h"

uint8_t* vga_current_address = (uint8_t*) vga_initial_address;

void clear_vga() {
    for(int i = 0; i < 80 * 25; i++) {
        *vga_current_address = 0x20;
        vga_current_address += 2;
    }
    vga_current_address = (uint8_t*) vga_initial_address;
}

void setup_vga() {
    vga_current_address++;
    for(int i = 0; i < 80 * 25; i++) {
        *vga_current_address = vga_color;
        vga_current_address += 2;
    }
    vga_current_address = (uint8_t*) vga_initial_address;
}

uint32_t str_length(char* str) {
    uint32_t length = 0;
    while(*str != 0) {
        str++;
        length++;
    }
    return length;
}

void print_string(char* str) {
    uint32_t length = str_length(str);
    for(int i = 0; i < length; i++) {
        *vga_current_address = *str;
        vga_current_address += 2;
        str++;
    }
}

uint32_t address_to_position() {
    return (uint32_t) (vga_current_address - vga_initial_address) / 2;
}

void print_line() {
    uint32_t absolute_pos = address_to_position();
    uint32_t relative_pos = absolute_pos % 80;
    for(int i = 0; i < 80 - relative_pos; i++) {
        vga_current_address += 2;
    }
}