#include "../lib/print.h"

void clear_vga() {
    uint8_t* vga_index = (uint8_t*) vga_address;
    for(int i = 0; i < 80 * 25 * 2; i++) {
        if(i % 2 == 0) *vga_index = 0x5f;
        else *vga_index = char_color;
        vga_index++;
    }
    vga_index = (uint8_t*) vga_address;
}