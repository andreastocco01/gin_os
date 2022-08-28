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

### GDT (Global Descriptor Table)
Per entrare in 32 bit protected mode bisogna creare la GDT, una struttura che definisce i segmenti di memoria e i loro attributi.
Ogni entry della tabella e' grande esattamente 8 byte e la sua struttura e' la seguente:
- 0....15   Limit           (4 byte inferiori del descrittore Limit)
- 16...31   Base            (4 byte inferiori del descrittore Base Address) 
- 32...39   Base            (2 byte mediani del descrittore Base Address)
- 40...47   Access Byte     (flag che descrivono chi ha accesso al segmento a cui fa riferimento questa entry)
- 48...51   Limit           (4 bit superiori del descrittore Limit)
- 52...55   Flags           (4 flag che influenzano la dimensione del segmento)
- 56...63   Base            (2 byte superiori del descrittore Base Address)

Con Access Byte cosi' suddiviso:
- 40        Ac      (Accessed: viene settato a 1 quando viene fatto un accesso a tale segmento. Inizialmente e' 0)
- 41        RW      (Readable (Code Segment): 1->Lettura. Non e' concessa scrittura. Writable (Data Segment): 1->Scrittura. E' sempre possibile Lettura)
- 42        DC      (Direction (Code Segment): 1 -> il codice puo' essere eseguito da un livello di privilegio inferiore. 0 -> eseguito solo da Privl
                     Conforming (Data Segment): 1 -> il segmento cresce verso il basso. Normalmente viene settato a 0)
- 43        Ex      (Executable: 1 -> il codice all'interno del segmento e' eseguibile)
- 44        S       (Descriptor: 1 -> code or data, 0 -> segmento di sistema)
- 45...46   Privl   (Privilege level: i privilegi vanno da 0 (kernel) a 3 (programmi utente))
- 47        Pr      (Present: e' settato a 1 se il segmento e' valido)

Con Flags suddiviso cosi':
- 52    A       (Available: non utilizzato dalla CPU, puo' essere settato a 0)
- 53    
- 54    Sz      (Size: 0 -> 16 bit protected mode. 1 -> 32 bit protected mode)
- 55    Gr      (Granularity: 0 -> Limit e' specificato in byte. 1 -> Limit e' specificato in pagine da 4KB)

Per entrare in 32 bit protected mode c'e' bisogno solo di 3 descrittori nella GDT:
- NULL descriptor (e' la prima entry della tabella e deve sempre esistere. Non descrive nessun segmento)
- 4 GB code descriptor
- 4 GB data descriptor

Code Segment e Data Segment sono grandi come tutta la memoria indirizzabile e sono sovrapposti. Non c'e' quindi nessun meccanismo di protezione. Questa configurazione si chiama Basic Flat Model. Viene quindi implementata una segmentazine "fittizia" solo per poter entrare in protected mode. Successivamente verra' implementato il paging per organizzare la memoria.

### Entrare in 32 bit protected mode
Una volta definita la GDT bisogna disabilitare gli interrupt (cli) perche' gli interrupt in real mode sono completamente diversi rispetto a quelli in protected mode e cio' rende la IVT (Interrupt Vector Table) definita dal BIOS completamente inutile. Inoltre, anche se si riuscisse ad eseguire una routine del BIOS, questa sarebbe a 16 bit e quindi non avrebbe idea di che cosa siano i segmenti a 32 bit definiti prima. Lo step successivo e' quello di comunicare alla CPU la GDT appena creata. Per farlo basta utilizzare il comando lgdt [gdt_descriptor]. Infine per effettuare lo switch, bisogna settare il primo bit di cr0 (Control Register: registro speciale della CPU a 32 bit che possiede diversi flag che modificano le operazioni di base del processore) a 1, in modo tale da attivare la protected mode.

I processori utilizzano la tecnica del pipelining che consente loro di portare avanti diversi stadi di esecuzione di un'istruzione in parallelo. Con lo switch, se la pipeline non viene svuotata, c'e' il rischio che le istruzioni successive vengano eseguite in modo errato. Quando la CPU conosce le prossime istruzioni da eseguire, la pipeline funziona molto bene (perche' riesce a fare il prefetch di esse). Cio' non accade quando la CPU esegue un salto o una chiamata a funzione.
Per svuotare la pipeline bastera' dunque eseguire un far jump (ossia saltare ad un' istruzione appartenente ad un altro segmento).

### Segmentazione
In real mode, il massimo indirizzo a cui possiamo accedere e' 0xffff (perche' la dimensione dei registri e' 16 bit). Ma la memoria disponibile e' molto piu' grande. Per poter utilizzare una maggior quantita' di memoria si ricorre alla segmentazione.
La memoria viene suddivisa in pezzi piu' piccoli chiamati segmenti e l'indirizzo di memoria effettivo all'interno di un segmento viene cosi' calcolato: fisico = 16 * sr (segment register: cs, ds, ss) + offset,  dove sr e' la base del segmento e offset e' l'indirizzo relativo che voglio raggiungere all'interno di esso. Il bus dell' i8086 era a 20 bit, quindi si riuscivano ad indirizzare 2^20 byte. Per poter usufruire di questo "spazio aggiuntivo", il segment register viene moltiplicato per 16 (ossia shiftato a sinistra di 4 bit) in modo tale da poter indirizzare 2^20 byte invece che 2^16. 

In protected mode le cose funzionano un po' diversamente: i segment register contengono l'indirizzo di un particolare selettore della GDT. Quando viene effettuato un accesso in memoria si va prima nel selettore della GDT specificato nel segment register, vengono effettuati dei controlli (es. controlla che l'indirizzo specificato non superi il limite, che tu abbia i permessi necessari per completare l'operazione ecc.) e infine viene calcolato l'indirizzo di memoria effettivo: fisico = base_segmento + offset

### Caricare e iniziare l'esecuzione del kernel
Prima di entrare il protected mode bisogna caricare in memoria il kernel (in protected mode le chiamate al BIOS sono disabilitate). Si prendono piu' settori del necessario per non rischiare di tralasciare una parte di kernel.
