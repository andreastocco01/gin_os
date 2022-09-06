#include "../lib/print.h"

uint8_t* vga_index = (uint8_t*) vga_address;

void clear_vga() {
    for(int i = 0; i < 80 * 25 * 2; i++) {
        if(i % 2 == 0) *vga_index = 0x20;
        else *vga_index = vga_color;
        vga_index++;
    }
    vga_index = (uint8_t*) vga_address;
}