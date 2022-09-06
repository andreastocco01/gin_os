#include <stdint.h>
#include "lib/print.h"

int main() {
    setup_vga();
    clear_vga();
    print_string("Il primo messaggio del kernel");
    return 0;
}