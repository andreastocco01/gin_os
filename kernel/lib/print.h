#ifndef PRINT_H
#define PRINT_H

#include <stdint.h>
#include <stdarg.h>

#define vga_initial_address 0xb8000 // la vga contiene 80x25 caratteri. Ogni cella e' composta da due bye: quello inferiore per il carattere,
                            // quello superiore per il colore di esso e dello sfondo. 
                            // es: byte 0xb8000 = 'X', byte 0xb8001 = 0x02 (0 = colore carattere, 2 = colore sfondo).

#define vga_color 0x0f // bianco su nero
#define vga_length 80
#define vga_height 25

extern uint8_t* vga_current_address; // cella di memoria corrente

void clear_vga();
void setup_vga();
void print_line();
void printf(char* string, ...);


#endif