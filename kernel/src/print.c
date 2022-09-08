#include "../lib/print.h"
#include "../lib/math.h"
#include "../lib/string.h"

uint8_t* vga_current_address = (uint8_t*) vga_initial_address;

void clear_vga() {
    for(uint16_t i = 0; i < vga_length * vga_height; i++) {
        *vga_current_address = 0x20;
        vga_current_address += 2;
    }
    vga_current_address = (uint8_t*) vga_initial_address;
}

void setup_vga() {
    vga_current_address++;
    for(uint16_t i = 0; i < vga_length * vga_height; i++) {
        *vga_current_address = vga_color;
        vga_current_address += 2;
    }
    vga_current_address = (uint8_t*) vga_initial_address;
}

void print_string(char* str) {
    uint32_t len = strlen(str);
    for(uint16_t i = 0; i < len; i++) {
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
    uint32_t relative_pos = absolute_pos % vga_length; // ricavo quante volte devo mandare avanti il cursore per andare a capo
    for(uint16_t i = 0; i < vga_length - relative_pos; i++) {
        vga_current_address += 2;
    }
}

uint32_t n_digits(int n) {
    if(n == 0) return 1;
    uint32_t digits = 1;
    uint32_t div = 10;
    while(n / div != 0) {
        digits++;
        div *= 10;
    }
    return digits;
}

void itoa(char* string, int n) {
    char str[10] = "";
    uint16_t i = 0;
    uint32_t digits = n_digits(n);
    uint32_t div = pow(10, digits - 1);
    uint32_t result = n;
    while(div != 1) {
        uint32_t reminder = result % div;
        result = result / div;
        str[i] = result + '0';
        i++;
        result = reminder;
        div /= 10;
    }
    str[i] = result + '0';
    strcopy(string, str);
}

void printf(char* string, ...) {
    va_list args;
    va_start(args, string); // comincio a scorrere i parametri della funzione a partire dall'ultimo parametro accettato.
                            // ogni invocazione di va_arg prende il parametro successivo.
    char buff[100] = "";
    uint16_t i = 0;
    while(*string != 0) {
        if(*string == '%') {
            string++; // salto questo carattere
            switch(*string) {
                case 'd': {
                    int arg = va_arg(args, int); // prendo l'intero da stampare
                    char str_arg [10];
                    itoa(str_arg, arg);
                    strcopy(&buff[i], str_arg);
                    i += strlen(str_arg);
                    break;
                }
                case 's': {
                    char* arg = va_arg(args, char*);
                    while(*arg != 0) {
                        buff[i] = *(arg++);
                        i++;
                    }
                }
            }
        } else {
            buff[i] = *string;
            i++;
        }
        string++;
    }
    print_string(buff);
    va_end(args);
}