# Kernel

## Bootloader
- $ indirizzo istruzione corrente
- $$ indirizzo sezione corrente <br />

$ - $$ fornisce l'offset tra l'istruzione corrente e la sezione corrente

Gli ultimi 2 byte devono essere utilizzati per il magic number 0xaa55 che dice al BIOS che si tratta di un boot block e non di semplici dati che si trovano nel primo settore del disco.
L'istruzione "times 510 - ($ - $$) db 0" rimpie di 0 lo spazio tra l'ultima istruzione e il 510 byte.
In questo modo si riesce a collocare il magic number nella posizione giusta.

### 32 bit protected mode
- i registri possono contenere 32 bit -> 4GB memoria indirizzabile <br />

In real mode ogni programma puo' accedere a qualsiasi cella di memoria, anche se e' utilizzata dal SO o da un altro programma.
Non c'e' quindi nessuna restrizione su cio' che un programma puo' o non puo' fare.
In protected mode la segmentazione offre principalmente due vantaggi:
- il codice di un segmento puo' essere interdetto dall'esecuzione del codice di un segmento piu' privilegiato, in modo da proteggere il codice del kernel dalle applicazioni utente.
- si puo' implementare la memoria virtuale in modo che le pagine di memoria di un processo possano essere spostate sul disco o in RAM in base alle necessita'. <br />

#### GDT (Global Descriptor Table)
Per entrare in 32 bit protected mode bisogna creare la GDT, una struttura che definisce i segmenti di memoria e i loro attributi.

