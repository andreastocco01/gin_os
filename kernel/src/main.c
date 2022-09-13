#include <stdint.h>
#include "../lib/print.h"

int main() {
    setup_vga();
    clear_vga();
    for(int i = 0; i < 25; i++) {
        printf("%d\n", i);
    }
    printf("new line after scrolling\n");
    printf("scrolled again\n");
    printf("new scroll\n");
    return 0;
}