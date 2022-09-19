#include "../lib/print.h"
#include "../lib/math.h"
#include "../lib/string.h"

uint8_t* vga_current_address = (uint8_t*) vga_first_address;

void clear_vga() {
    vga_current_address = (uint8_t*) vga_first_address;
    for(uint32_t i = 0; i < vga_length * vga_height; i++) {
        *vga_current_address = 0x20;
        vga_current_address += 2;
    }
    vga_current_address = (uint8_t*) vga_first_address;
}

void setup_vga() {
    vga_current_address++;
    for(uint32_t i = 0; i < vga_length * vga_height; i++) {
        *vga_current_address = vga_color;
        vga_current_address += 2;
    }
    vga_current_address = (uint8_t*) vga_first_address;
}

void scroll_screen() {
    uint8_t* from = (uint8_t*) vga_second_line_address; // primo indirizzo della seconda riga della vga
    // sposto ogni riga sulla sua precedente
    while(from <= (uint8_t*) vga_last_address) { // ultimo indirizzo della vga
        uint8_t* to = from - 0xa0;
        *to = *from;
        to += 2;
        from += 2;
    }
    // cancello l'ultima riga
    from = (uint8_t*) vga_last_line_address;
    while(from <= (uint8_t*) vga_last_address) {
        *from = 0x20;
        from += 2;
    }
}

uint32_t address_to_position() {
    return (uint32_t) (vga_current_address - vga_first_address) / 2;
}

void print_line() {
    uint32_t absolute_pos = address_to_position();
    uint32_t relative_pos = absolute_pos % vga_length; // ricavo quante volte devo mandare avanti il cursore per andare a capo
    for(uint32_t i = 0; i < vga_length - relative_pos; i++) {
        vga_current_address += 2;
    }
}

void print_string(char* str) {
    while(*str != 0) {
        if(vga_current_address == (uint8_t*) vga_first_out_address) { // primo indirizzo al di fuori della vga
            scroll_screen();
            vga_current_address -= 0xa0;
        }
        if(*str == '\n'){
            print_line();
        }
        else {
            *vga_current_address = *str;
            vga_current_address += 2;
        }
        str++;
    }
}

uint32_t n_digits(uint32_t n) {
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
    uint32_t i = 0;
    if(n < 0) {
        string[i++] = '-';
        n = -n;
    }
    uint32_t digits = n_digits(n);
    uint32_t div = pow(10, digits - 1);
    uint32_t result = n;
    while(div != 1) {
        uint32_t reminder = result % div;
        result = result / div;
        string[i++] = result + '0';
        result = reminder;
        div /= 10;
    }
    string[i] = result + '0';
}

void printf(char* string, ...) {
    va_list args;
    va_start(args, string); // comincio a scorrere i parametri della funzione a partire dall'ultimo parametro accettato.
                            // ogni invocazione di va_arg prende il parametro successivo.
    char buff[100] = "";
    uint32_t i = 0;
    while(*string != 0) {
        if(*string == '%') {
            string++; // salto questo carattere
            switch(*string) {
                case 'd': {
                    // prendo l'intero da stampare
                    char str_arg [20] = "";
                    itoa(str_arg, va_arg(args, int));
                    strcpy(&buff[i], str_arg);
                    i += strlen(str_arg);
                    break;
                }
                case 'c': {
                    buff[i++] = va_arg(args, int);
                    break;
                }
                case 's': {
                    char* arg = va_arg(args, char*);
                    while(*arg != 0) {
                        buff[i++] = *(arg++);
                    }
                    break;
                }
            }
        } else {
            buff[i++] = *string;
        }
        string++;
    }
    print_string(buff);
    va_end(args);
}