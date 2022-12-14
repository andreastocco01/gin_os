# GinOS

## Struttura del progetto

Il progetto e' suddiviso in due parti: il `bootloader` e il `kernel`

### Bootlaoder

Questa sezione del progetto si occupa di:

- passare dalla real mode alla long mode (passando per la protected mode)

- caricare il kernel in memoria

- passare all' esecuzione di esso

Il primo settore del disco viene riconosciuto come boot block dal BIOS solo se i suoi ultimi due byte contengono il magic number 0xaa55.
L'istruzione `times 510 - ($ - $$) db 0` rimpie di 0 lo spazio tra l'ultima istruzione e il 510esimo byte ($ - $$ fornisce l'offset tra l'istruzione corrente e la sezione corrente).
In questo modo si riesce a collocare il magic number nella posizione giusta.
Per il BIOS, quindi, il bootloader deve essere grande esattamente 512 byte, ma tale spazio e' al quanto riduttivo per poter implementare tutte le funzioni sopracitate.
Per questo motivo e' stato suddiviso in due parti (multistage bootloader):

- `first stage` si occupa esclusivamente di caricare in memoria `second stage` che non ha limitazioni sulla dimensione!
- `second stage` si occupa di passare in 64 bit long mode, caricare il kernel in memoria e iniziare l'esecuzione di esso.

### Kernel

Questa sezione del progetto si occupa di:

- creare la IDT (Interrupt Descriptor Table)

- `TODO`

## 32 bit protected mode

- i registri possono contenere 32 bit -> 4GB memoria indirizzabile

In real mode ogni programma puo' accedere a qualsiasi cella di memoria, anche se e' utilizzata dal SO o da un altro programma.
Non c'e' quindi nessuna restrizione su cio' che un programma puo' o non puo' fare.
In protected mode la segmentazione offre principalmente due vantaggi:

- il codice di un segmento puo' essere interdetto dall'esecuzione del codice di un segmento piu' privilegiato, in modo da proteggere il codice del kernel dalle applicazioni utente.
- si puo' implementare la memoria virtuale in modo che le pagine di memoria di un processo possano essere spostate sul disco o in RAM in base alle necessita'.

## Segmentazione

In real mode, il massimo indirizzo a cui possiamo accedere e' 0xffff (perche' la dimensione dei registri e' 16 bit). Ma la memoria disponibile e' molto piu' grande. Per poter utilizzare una maggior quantita' di memoria si ricorre alla segmentazione.
La memoria viene suddivisa in pezzi piu' piccoli chiamati segmenti e l'indirizzo di memoria effettivo all'interno di un segmento viene cosi' calcolato: `fisico = 16 * sr (segment register: cs, ds, ss) + offset`,  dove sr e' la base del segmento e offset e' l'indirizzo relativo che voglio raggiungere all'interno di esso. Il bus dell' i8086 era a 20 bit, quindi si riuscivano ad indirizzare 2^20 byte. Per poter usufruire di questo "spazio aggiuntivo", il segment register viene moltiplicato per 16 (ossia shiftato a sinistra di 4 bit) in modo tale da poter indirizzare 2^20 byte invece che 2^16.

In protected mode le cose funzionano un po' diversamente: i segment register contengono l'indirizzo di un particolare selettore della GDT. Quando viene effettuato un accesso in memoria si va prima nel selettore della GDT specificato nel segment register, vengono effettuati dei controlli (es. controlla che l'indirizzo specificato non superi il limite, che tu abbia i permessi necessari per completare l'operazione ecc.) e infine viene calcolato l'indirizzo di memoria effettivo: `fisico = base_segmento + offset`

## GDT (Global Descriptor Table)

Per entrare in 32 bit protected mode bisogna creare la GDT, una struttura che definisce i segmenti di memoria e i loro attributi.

```text
Ogni entry della tabella e' grande esattamente 8 byte e la sua struttura e' la seguente:
- 0....15   Limit           (2 byte inferiori del descrittore Limit)
- 16...31   Base            (2 byte inferiori del descrittore Base Address) 
- 32...39   Base            (1 byte mediano del descrittore Base Address)
- 40...47   Access Byte     (flag che descrivono chi ha accesso al segmento a cui fa riferimento questa entry)
- 48...51   Limit           (4 bit superiori del descrittore Limit)
- 52...55   Flags           (4 flag che influenzano la dimensione del segmento)
- 56...63   Base            (2 byte superiori del descrittore Base Address)

Con Access Byte cosi' suddiviso:
- 40        Ac      (Accessed: viene settato a 1 quando viene fatto un accesso a tale segmento. Inizialmente e' 0)
- 41        RW      (Readable (Code Segment): 1 -> Lettura. Non e' concessa scrittura. Writable (Data Segment): 1 -> Scrittura. E' sempre possibile Lettura)
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
```

Per entrare in 32 bit protected mode c'e' bisogno solo di 3 descrittori nella GDT:

- NULL descriptor (e' la prima entry della tabella e deve sempre esistere. Non descrive nessun segmento)
- 4 GB code descriptor
- 4 GB data descriptor

Code Segment e Data Segment sono grandi come tutta la memoria indirizzabile e sono sovrapposti. Non c'e' quindi nessun meccanismo di protezione. Questa configurazione si chiama Basic Flat Model. Viene quindi implementata una segmentazine "fittizia" solo per poter entrare in protected mode. Successivamente verra' implementato il paging per organizzare la memoria.

## Entrare in 32 bit protected mode

Una volta definita la GDT bisogna abilitare la A20 line (da capire) e disabilitare gli interrupt (`cli`) perche' gli interrupt in real mode sono completamente diversi rispetto a quelli in protected mode e cio' rende la IVT (Interrupt Vector Table) definita dal BIOS completamente inutile. Inoltre, anche se si riuscisse ad eseguire una routine del BIOS, questa sarebbe a 16 bit e quindi non avrebbe idea di che cosa siano i segmenti a 32 bit definiti prima. Lo step successivo e' quello di comunicare alla CPU la GDT appena creata. Per farlo basta utilizzare il comando `lgdt [gdt_descriptor]`. Infine per effettuare lo switch, bisogna settare il primo bit di cr0 (Control Register: registro speciale della CPU a 32 bit che possiede diversi flag che modificano le operazioni di base del processore) a 1, in modo tale da attivare la protected mode.

I processori utilizzano la tecnica del pipelining che consente loro di portare avanti diversi stadi di esecuzione di un'istruzione in parallelo. Con lo switch, se la pipeline non viene svuotata, c'e' il rischio che le istruzioni successive vengano eseguite in modo errato. Quando la CPU conosce le prossime istruzioni da eseguire, la pipeline funziona molto bene (perche' riesce a fare il prefetch di esse). Cio' non accade quando la CPU esegue un salto o una chiamata a funzione.
Per svuotare la pipeline bastera' dunque eseguire un far jump (ossia saltare ad un' istruzione appartenente ad un altro segmento).

## 64 bit long mode

In long mode i registri possono contenere 64 bit -> 2^64 byte di memoria indirizzabile (17'179'869'184 GB)
Diversamente dalla protected mode, che puo' girare con o senza paging, in long mode il paging (in particolare il PAE paging) e' obbligatorio. La segmentazione non viene utilizzata.

## PAE paging

La paginazione PAE e' un tipo di paginazione in cui sono presenti le seguenti tabelle: page-directory pointer table (`PDPT`), page-directory table (`PDT`) e page table (`PT`). C'?? anche un'altra tabella che costituisce la radice della paginazione gerarchica ed ?? la page-map level-4 table (`PML4T`). In protected mode le entry di una page table erano lunghe solo 4 byte, quindi c'erano 1024 entry per tabella. In long mode, invece, si hanno solo 512 entry per tabella, poich?? ogni entry ?? lunga 8 byte. Ci?? significa che le PT entry possono indirizzare 4kB, le PDT entry possono indirizzare 2MB, le PDPT entry possono indirizzare 1GB e le PML4T entry possono indirizzare 512GB. E' quindi possibile indirizzare solo 256 TB. Il funzionamento di queste tabelle prevede che ogni entry della PML4T punti a una PDPT, ogni entry di una PDPT a una PDT e ogni entry di una PDT a una PT. Ogni entry di un PT punta poi all'indirizzo fisico.

## Entrare in 64 bit long mode

La long mode non e' supportata da tutti i processori. Per verificare che il processore in questione supporti la long mode si ricorre alla chiamata di una funzione speciale chiamata `CPUID`. Tale funzione ritorna diverse informazioni sul processore in base all'argomento che gli viene passato.
Per prima cosa si verifica che tale istruzione sia supportata: cio' accade se si riesce a flippare il 21 bit del registro FLAGS.
Se tale test va a buon fine l'istruzione CPUID puo' essere chiamata per capire se la long mode e' supportata. Passandole come parametro il valore `0x80000001`, CPUID ritorna nei registri `ecx` e `edx` alcune informazioni utili sul processore. Se il 29esimo bit ritornato all'interno del registro edx e' settato, significa che il processore e' in grado di entrare in long mode.

PAE paging e' obbligatorio per la long mode. Bisogna quindi implementare il PAE paging e abilitarlo.
Dopo aver creato le page tables, devo implementare l'identity paging. Per farlo basta collegare ognuna delle 512 entry della PD table all'indirizzo di una PT in memoria (grande 2MB) e collegare P4 -> P3 -> P2.
Per abilitare il PAE e', infine, sufficiente mettere dentro al registro `cr3` l'indirizzo della PML4T e settare il quinto bit del registro `cr4`.
Poi si abilita il paging settando il 31esimo bit del registro `cr0`.
Successivamente e' possibile entrare in long mode attraverso un far jump (come nel caso della protected mode).
Prima di fare questo e' pero' necessario aggiornare i selettori della GDT per far si che si riferiscano a segmenti di 64 bit.

## Caricare e iniziare l'esecuzione del kernel

Prima di entrare in protected mode bisogna caricare in memoria il kernel (in protected mode le chiamate al BIOS sono disabilitate). Bisognerebbe conoscere la dimensione del kernel in modo da caricare il numero esatto di settori (da capire). Una volta caricato il kernel in memoria all'indirizzo 0x2000 una semplice call a tale indirizzo in long mode permette di eseguire il codice del kernel. In questo modo si salta alla prima istruzione del kernel... non e' detto che sia l'entry point desiderato. Per risolvere il problema basta creare un nuovo file assembly (da posizionare prima dell'inizio del kernel tramite il linker) che chiama la funzione desiderata. In questo modo, spostandosi all'indirizzo di memoria 0x2000, non ci si sposta piu' nella prima istruzione del kernel vero e proprio (che potrebbe non essere quella desiderata), bensi' alla prima istruzione del nuovo file assembly. Da qui si chiama la funzione desiderata del kernel.

## IDT (Interrupt Descriptor Table)

Struttura IDT in long mode (vedere OSDev per IDT in protected mode).

Gli interrupt possono essere pensati come delle notifiche che avvertono la CPU di un evento avvenuto nel sistema.
Quando avviene un interrupt la CPU deve salvare lo stato attuale del sistema prima di poter eseguire la routine per soddisfare tale segnale.
L'IDT e' una tabella contenente esattamente 256 entrate grandi 8 byte ciascuna cosi' definite:

```text
- 0....15  Offset        (2 byte inferiori del descrittore Offset)
- 16...31  Selector
- 32...34  IST
- 35...39  Reserved
- 40...43  Gate Type
- 44       Zero
- 45...46  DPL
- 47       P
- 48...63  Offset        (2 byte mediani del descrittore Offset)
- 64...95  Offset        (2 byte superiori del descrittore Offset)
- 96...127 Reserved
```

con

```text
- Offset: indirizzo dell' entry point dell'ISR (Interrupt Service Routine)
- Selector: punta ad una entry della GDT
- IST: offset all' interno della Interrupt Stack Table, salvata nel Task State Segment. 000 -> Interrupt Stack Table non utilizzata
- Gate Type: le IDT entry vengono chiamate gate. In long mode esistono solo 2 tipi di gate:
    - 0b1110 -> Interrupt Gate
    - 0b1111 -> Trap Gate
- DPL: definisce i livelli di privilegio della CPU che possono accedere a questo interrupt tramite l'istruzione INT. Gli interrupt hardware ignorano questo meccanismo.
- P: present bit. Deve essere 1 affinche' tale gate sia valido.
```

Esistono dunque due tipi di gate:

- Interrupt Gate: viene utilizzato per specificare una ISR. Quando viene generato un interrupt (ad esempio `int 30`) la CPU guarda all'interno della IDT alla posizione `indirizzo prima entry IDT + 30 * 8`. In questo caso Selector e Offset vengono utilizzati per chiamare L'ISR corretta.
- Trap Gate: viene utilizzata per gestire le eccezioni. Interrupt Gates e Trap Gates sono praticamente la stessa cosa. Differiscono solo per il Gate Type e per il fatto che gli interrupt vengono momentaneamente disabilitati con gli Interrupt Gate.

## Debug kernel

Su un terminale eseguire qemu in debug mode.
Su un altro terminale:

- gdb
- target remote :1234
- layout asm
- set disassembly-flavor intel
- break ...
