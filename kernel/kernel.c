#include <stdint.h>
#include "lib/print.h"

int main() {
    setup_vga();
    clear_vga();
    print_string("First line");
    print_line();
    print_string("Second line");
    print_line();
    print_string("Third line very very long");
    print_string(" create with the concatenation of different strings");
    print_string(" with more of 80 characters");
    print_line();
    print_string("Fourth line in the correct position");
    print_line();
    print_int(0);
    print_line();
    print_int(3);
    print_line();
    print_int(12);
    print_line();
    print_int(495);
    print_line();
    print_int(3905);
    print_line();
    print_int(49586);
    print_line();
    return 0;
}