int main(void)
{
    //Prints a "X" on the upper-left corner
    char * vga = (char *) 0xb8000 ;
    *vga = 'X';

    while(1){};
    return 1;

}