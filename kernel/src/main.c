#include <stdint.h>
#include "../lib/string.h"
#include "../lib/print.h"

int main() {
    setup_vga();
    clear_vga();
    printf("ciao \nvado a capo\nsono andato a capo\ndi nuovo\n");
    printf("ciao questo e' un \nnumero: %d\n", 9);
    for(int i = 10; i < 16; i++) {
        printf("stampo un numero e vado a capo: %d\n", i);
    }
    printf("stampo un nuovo\nnumero %d\n", 27464);
    printf("roba a caso\n%s\n", "concateno una stringa");
    printf("%d\n", 4);
    for(int i = 0; i < 11; i++) {
        printf("%d\n", i);
    }
    printf("nuova riga\n");
    printf("stringa con piu' di 80 caratteri jsaoghirewopbhficoparghfiorpewgrpoagntruep9wigowgnuiroebgi\n");
    printf("ultima\nstringa%s", " con\nconcatenazione\n");
    printf("altra riga\n");
    printf("stampo un' intero %d\n", 789);
    printf("stampo un\nnumero negativo %d\n", -78);
    printf("%s %d %d\n", "stringa", 48765, -3857);
    printf("stampo un carattere %c\n", 'x');
    printf("ultima stringa");
    return 0;
}