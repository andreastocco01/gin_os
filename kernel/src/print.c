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
    uint32_t relative_pos = absolute_pos % 80; // ricavo quante volte devo mandare avanti il cursore per andare a capo
    for(int i = 0; i < 80 - relative_pos; i++) {
        vga_current_address += 2;
    }
}

uint32_t n_digits(int n) {
    if(n == 0) return 1;
    int digits = 1;
    int div = 10;
    while(n / div != 0) {
        digits++;
        div *= 10;
    }
    return digits;
}

int pow(int base, int exp) {
    int res = 1;
    for(int i = 0; i < exp; i++) {
        res = res * base;
    }
    return res;
}

void print_int(int n) {
    if(n == 0) *vga_current_address = n + '0';
    uint32_t digits = n_digits(n);
    int div = pow(10, digits - 1);
    int result = n;
    int reminder = 0;
    while(result != 0) {
        reminder = result % div;
        result = result / div;
        *vga_current_address = result + '0';
        vga_current_address += 2;
        result = reminder;
        div /= 10;
    }
}