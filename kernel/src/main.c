#include <stdint.h>
#include "../lib/string.h"
#include "../lib/print.h"

int main() {
    setup_vga();
    clear_vga();
    printf("ciao \n vado a capo\n sono andato a capo\ndi nuovo\n");
    printf("ciao questo e' un \nnumero: %d\n", 9);
    for(int i = 10; i < 16; i++) {
        printf("stampo un numero e vado a capo: %d\n", i);
    }
    printf("stampo un nuovo\n numero %d\n", 4);
    printf("roba a caso\n");
    printf("%d", 4);
    return 0;
}