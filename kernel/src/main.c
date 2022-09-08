#include <stdint.h>
#include "../lib/print.h"

int main() {
    setup_vga();
    clear_vga();
    printf("First line");
    print_line();
    printf("%d", 10);
    print_line();
    printf("Strings and number: %d, %d.", 2540, 10329);
    printf(" Writing in the same line and go to a new one when the space ends");
    print_line();
    printf("Another string with a number %d", 473009);
    print_line();
    printf("Concatenation of two strings: %s, %s", "first string", "second string");
    return 0;
}