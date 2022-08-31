#define vga_address 0xb8000 // la vga contiene 80x25 caratteri. Ogni cella e' composta da due bye: quello inferiore per il carattere,
                            // quello superiore per il colore di esso e dello sfondo. 
                            // es: byte 0xb8000 = 'X', byte 0x8001 = 0x02 (0 = colore carattere, 2 = colore sfondo).

typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int uint32;

void print_string(char* memory_location, char* message) {
    while(*message != 0) {
        *memory_location = *message;
        message++;
        memory_location += 2;
    }
}

int main() {
    char* video_memory = (char*) vga_address;
    char* string = "primo messaggio vero dal kernel";
    print_string(video_memory + 160, string); // lo scrivo su una nuova linea
    //print_string(video_memory + 80 - 31, string2);
    // print_int(video_memory, size);
    return 0;
}