#ifndef PRINT_H
#define PRINT_H

#include <stdint.h>
#include <stdarg.h>

#define vga_first_address 0xb8000 // la vga contiene 80x25 caratteri. Ogni cella e' composta da due bye: quello inferiore per il carattere,
                            // quello superiore per il colore di esso e dello sfondo. 
                            // es: byte 0xb8000 = 'X', byte 0xb8001 = 0x02 (0 = colore carattere, 2 = colore sfondo).

#define vga_color 0x0f // bianco su nero
#define vga_length 80
#define vga_height 25
#define vga_first_out_address 0xb8fa0
#define vga_second_line_address 0xb80a0
#define vga_last_address 0xb8f9e
#define vga_last_line_address 0xb8f00

extern uint8_t* vga_current_address; // cella di memoria corrente

void clear_vga();
void setup_vga();
void printf(char* string, ...);


#endif