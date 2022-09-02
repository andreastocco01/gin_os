#include <stdint.h>
#include "lib/print.h"

int main() {
    char* video_memory = (char*) 0xb8000;
    *video_memory = 's';
    clear_vga();
    return 0;
}