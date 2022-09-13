#include <stdint.h>
#include "../lib/print.h"

int main() {
    setup_vga();
    clear_vga();
    for(int i = 0; i < 25; i++) {
        printf("%d", i);
        print_line();
    }
    printf("new line after scrolling");
    print_line();
    printf("scrolled again");
    print_line();
    print_line();
    printf("new scroll");
    return 0;
}