# Kernel

### Bootloader
- $ indirizzo istruzione corrente
- $$ indirizzo sezione corrente <br />

$ - $$ fornisce l'offset tra l'istruzione corrente e la sezione corrente

Gli ultimi 2 byte devono essere utilizzati per il magic number 0xaa55 che dice al BIOS che si tratta di un boot block e non di semplici dati che si trovano nel primo settore del disco.
L'istruzione "times 510 - ($ - $$) db 0" rimpie di 0 lo spazio tra l'ultima istruzione e il 510 byte.
In questo modo si riesce a collocare il magic number nella posizione giusta.

