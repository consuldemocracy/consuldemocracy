# Indice

*   [Funzionalità](#funcionalidades)
*   [Registrazione utente](#registro-de-usuario)
*   [Profilo utente](#perfil-de-usuario)
*   [Profili di amministratore, moderatore e amministratore](#perfiles-de-administrador,-moderador-y-gestor)
*   [Profili di valutatore e sedia da tavolo](#perfiles-de-evaluador-y-presidente-de-mesa)

## Funzionalità

CONSUL attualmente supporta:

*   Registrazione e verifica degli utenti sia nella stessa applicazione che con diversi provider (Twitter, Facebook, Google).
*   Diversi profili utente, sia singoli cittadini e organizzazioni che funzionari pubblici.
*   Diversi profili di amministrazione, gestione, valutazione e moderazione.
*   Spazio permanente per dibattiti e proposte.
*   Commenti annidati in dibattiti e proposte.
*   Budgeting partecipativo attraverso diverse fasi.

## Registrazione utente

Per registrare un nuovo utente è possibile farlo nell'applicazione stessa, dando un nome utente (nome pubblico che apparirà nelle tue pubblicazioni), una mail e una password con cui si accederà al web. Le condizioni d'uso devono essere accettate. L'utente deve confermare la propria e-mail per poter accedere.

![Registro de usuario](imgs/user_registration.png "Registro de usuario")

D'altra parte, la registrazione può essere abilitata anche attraverso servizi esterni come Twitter, Facebook e Google. Per questo è necessario avere la configurazione abilitata in Impostazioni e le chiavi e i segreti di questi servizi nel file *config/secrets.yml*.

      twitter_key: ""
      twitter_secret: ""
      facebook_key: ""
      facebook_secret: ""
      google_oauth2_key: ""
      google_oauth2_secret: ""

Una volta effettuato l'accesso, apparirà la possibilità di verificare il proprio account, attraverso un collegamento con il registro comunale.

![Verificación de usuario](imgs/user_preverification.png?raw=true "Verificación de usuario")

Per questa funzionalità è necessario che il registro comunale supporti la possibilità di connessione tramite un'API, è possibile vedere un esempio in *lib/census_api.rb*.

![Verificación de usuario](imgs/user_verification.png?raw=true "Verificación de usuario")

## Profilo utente

All'interno del proprio profilo ("Il mio account" nel menu in alto) ogni utente può configurare se desidera visualizzare pubblicamente il proprio elenco di attività, nonché le notifiche che l'applicazione invierà loro via e-mail. Queste notifiche possono essere:

*   Ricevi un'e-mail quando qualcuno commenta le tue proposte o discussioni.
*   Ricevi un'email quando qualcuno risponde ai tuoi commenti.
*   Ricevi e-mail con informazioni interessanti sul web.
*   Ricevi un riepilogo delle notifiche sulle proposte.
*   Ricevi e-mail con messaggi privati.

## Profili di amministratore, moderatore e amministratore

CONSUL ha tre profili utente per gestire i contenuti web: amministratore, moderatore e manager. Ha anche altri due profili per la gestione partecipativa dei processi: [valutatore e sedia da tavolo](#perfiles_de_evaluador,\_gestor_y_presidente_de_mesa), che sono dettagliati di seguito.

Gli utenti con un profilo amministratore possono assegnare qualsiasi tipo di profilo a qualsiasi tipo di utente. Tuttavia, tutti i profili devono essere utenti verificati (a differenza del registro comunale) per poter eseguire determinate azioni (ad esempio, i manager devono essere verificati per creare progetti di spesa).

### Pannello Gestisci

![Panel de administración](imgs/panel_administration.png?raw=true "Panel de administración")

Da qui è possibile gestire il sistema, attraverso i seguenti menu:

#### Categorie ![categorias](imgs/icon_categories.png?raw=true "categorías")

##### Argomenti di discussione/proposta

Gli argomenti (chiamati anche tag, o tag) sono parole che definiscono gli utenti quando creano dibattiti o proposte per facilitare la loro catalogazione (ad esempio: salute, mobilità, arganzuela, ...). Da qui l'amministratore ha le seguenti opzioni:

*   Creare nuovi temi
*   Rimuovere argomenti inappropriati
*   Contrassegnare gli argomenti in modo che vengano visualizzati come suggerimenti durante la creazione di discussioni/proposte. Ogni utente può creare quelli che desidera, ma l'amministratore può suggerirne alcuni che trova utili come catalogazione predefinita. Selezionando "Proponi argomento durante la creazione della proposta" su ciascun argomento, imposta quali sono suggeriti.

#### Contenuto moderato ![contenido moderado](imgs/icon_moderated_content.png?raw=true "contenido moderado")

##### Proposte/Dibattiti/Commenti nascosti

Quando un amministratore o un moderatore nasconde una proposta/discussione/commento dal Web, questa verrà visualizzata in questo elenco. In questo modo gli amministratori possono rivedere gli elementi che sono stati nascosti e correggere eventuali errori.

*   Facendo clic su "Conferma" viene accettato quello che è stato nascosto; si ritiene che sia stato fatto correttamente.
*   Se si ritiene che l'occultamento sia stato errato, cliccando su "Mostra di nuovo" si inverte l'azione di occultamento e si torna ad essere una Proposta/Dibattito/Commento visibile sul web.

Per facilitare la gestione, sopra troviamo un filtro con le sezioni: "In sospeso" (gli elementi su cui "Conferma" o "Mostra" non sono ancora stati cliccati, che dovrebbero comunque essere rivisti), "Confermato" e "Tutti".

Si consiglia di controllare regolarmente la sezione "In sospeso".

#### Utenti bloccati

Quando un moderatore o un amministratore blocca un utente dal Web, questi vengono visualizzati in questo elenco. Quando un utente viene bloccato, non può eseguire azioni sul web e tutte le sue proposte / dibattiti / commenti non saranno più visibili.

*   Cliccando su "Conferma" il blocco viene accettato; si ritiene che sia stato fatto correttamente.
*   Se il blocco è considerato errato, facendo clic su "Mostra di nuovo" si inverte il blocco e l'utente è di nuovo attivo.

#### Voti ![votaciones](imgs/icon_polls.png?raw=true "votaciones")

Puoi creare una votazione facendo clic su "Crea voto" e definendo un nome, una data di apertura e di chiusura. Inoltre, il voto può essere limitato a determinate aree selezionando "Limita per zone". Le zone disponibili sono definite nel menu [Gestire i distretti](#gestionar-distritos).

Gli utenti devono essere verificati per poter partecipare alla votazione.

Una volta creato il voto, i suoi componenti vengono definiti e aggiunti. I voti hanno tre componenti: domande dei cittadini, tabella dei presidenti e posizione delle urne.

##### Domande dei cittadini

Puoi creare una domanda cittadina o cercarne una esistente. Quando si crea la domanda può essere assegnato a un determinato voto. Puoi anche modificare l'assegnazione a una domanda esistente premendola e selezionando "Modifica".

Dalla sezione Domande dei cittadini, anche le proposte dei cittadini che hanno superato la soglia di sostegno possono essere assegnate a un voto. Possono essere selezionati dalla scheda "Proposte che hanno superato la soglia".

##### Presidenti

Qualsiasi utente registrato sul web può diventare un Table Chair. Per assegnargli quel ruolo, la sua email viene inserita nel campo di ricerca e una volta trovata viene assegnata con "Aggiungi come Presidente tabella". Quando i presidenti accedono al web con il loro utente vedono in alto una nuova sezione chiamata "Presidenti da tavolo".

##### Ubicazione delle urne elettorali

Per aggiungere un'urna all'elenco, selezionare "Aggiungi urna", quindi inserire il nome dell'urna e i dati sulla posizione.

#### Bilancio partecipativo ![presupuestos participativos](imgs/icon_participatory_budgeting.png?raw=true "presupuestos participativos")

Da questa sezione è possibile creare un budget partecipativo selezionando "Crea nuovo budget" o modificarne uno esistente. Modificando è possibile modificare la fase in cui si trova il processo; questo cambiamento si rifletterà sul web. È inoltre possibile creare gruppi di voci di budget e aggiungere progetti di spesa creati in precedenza da un [direttore](#panel-gestión).

#### Profili ![perfiles](imgs/icon_profiles.png?raw=true "perfiles")

##### Organizzazioni

Sul web qualsiasi utente può registrarsi con un profilo individuale o come organizzazione. Gli utenti delle organizzazioni possono essere verificati dagli amministratori, confermando che chi gestisce l'utente rappresenta effettivamente tale organizzazione. Una volta effettuato il processo di verifica, dal processo esterno al web che è stato definito per esso, viene premuto il pulsante "Verifica" per confermarlo; che farà apparire un'etichetta accanto al nome dell'organizzazione che indica che si tratta di un'organizzazione verificata.

Nel caso in cui il processo di verifica sia stato negativo, viene premuto il pulsante "Rifiuta". Per modificare i dati dell'organizzazione, fai clic sul pulsante "Modifica".

Le organizzazioni che non appaiono nell'elenco possono essere trovate per agire su di loro attraverso il motore di ricerca in alto. Per facilitare la gestione, sopra troviamo un filtro con le sezioni: "in sospeso" (organizzazioni che non sono ancora state verificate o rifiutate), "verificato", "rifiutato" e "tutto".

Si consiglia di rivedere regolarmente la sezione "in sospeso".

##### Uffici Pubblici

Lo status di ufficio pubblico non può essere scelto nella registrazione che viene effettuata dal web: viene assegnato direttamente da questa sezione. L'amministratore cerca un utente inserendo la sua email nel campo di ricerca e assegna loro il ruolo di Ufficio Pubblico.

L'ufficio pubblico differisce dal singolo utente solo in quanto un'etichetta che lo identifica appare accanto al suo nome e cambia leggermente lo stile dei suoi commenti. Ciò consente agli utenti di identificarti più facilmente. Accanto a ogni carica vediamo l'identificazione che appare sulla sua etichetta e il suo livello (il modo in cui il web utilizza internamente per distinguere tra un tipo di addebito e altri). Premendo il pulsante "Modifica" accanto all'utente, le sue informazioni possono essere modificate. I funzionari pubblici che non compaiono nell'elenco possono essere trovati ad agire su di loro attraverso il motore di ricerca in alto.

##### Moderatori

Qualsiasi utente registrato sul web può diventare un moderatore. Per assegnare quel ruolo, la tua email viene inserita nel campo di ricerca e una volta trovata viene assegnata con "Aggiungi come Moderatore". Quando i moderatori accedono al web con il loro utente vedono in alto una nuova sezione chiamata "Moderato".

Selezionando "Attività moderatore" viene visualizzato un elenco di tutte le azioni eseguite dai moderatori: nascondere/mostrare proposte/discussioni/commenti e bloccare gli utenti. Nella colonna "Azione" controlliamo se l'azione corrisponde a nascondere o mostrare (ripristinare) elementi o a bloccare gli utenti. Nelle altre colonne abbiamo il tipo di elemento, il contenuto dell'elemento e il moderatore o l'amministratore che ha eseguito l'azione.

Questa sezione consente agli amministratori di rilevare comportamenti irregolari da parte di moderatori specifici e quindi di essere in grado di correggerli.

##### Valutatori

Qualsiasi utente registrato sul web può diventare un valutatore. Per assegnare quel ruolo, la tua email viene inserita nel campo di ricerca e una volta trovata viene assegnata con "Aggiungi come valutatore". Quando i valutatori accedono al web con il loro utente vedono in alto una nuova sezione chiamata "Valutazione".

##### Managers

Qualsiasi utente registrato sul sito web può diventare un manager. Per assegnare quel ruolo, la tua email viene inserita nel campo di ricerca e una volta trovata viene assegnata con "Aggiungi come gestore". Quando i manager accedono al sito web con il loro utente vedono in alto una nuova sezione chiamata "Gestione".

#### Banner ![banners](imgs/icon_banners.png?raw=true "banners")

Dal menu "Gestisci banner" è possibile creare banner per fare annunci speciali che appariranno sempre in cima al web, sia nelle sezioni discussioni che proposte. Per crearlo devi selezionare "Crea banner" e inserire i tuoi dati e le date di inizio e fine della pubblicazione in formato `dd/mm/aaa`.

Per impostazione predefinita, sul Web verrà visualizzato un solo banner. Se ci sono diversi banner le cui date indicano che dovrebbero essere attivi, verrà visualizzato solo quello la cui data di inizio della pubblicazione è più vecchia.

#### Personalizza sito ![personalizar sitio](imgs/icon_customize_site.png?raw=true "personalizar sitio")

##### Personalizza le pagine

Le pagine servono a visualizzare qualsiasi tipo di contenuto statico relativo ai processi di partecipazione. Quando si crea o si modifica una pagina è necessario immettere un *Lumaca* Per definire la proprietà *permalink* di quella pagina in questione. Una volta creato, possiamo accedervi dall'elenco, selezionando "Visualizza pagina".

##### Personalizza le immagini

Da questo pannello vengono definite le immagini degli elementi aziendali del tuo CONSUL.

##### Personalizza i blocchi

Puoi creare blocchi HTML che verranno incorporati nell'intestazione o nel piè di pagina del tuo CONSUL.

I blocchi di intestazione (top_links) sono blocchi di collegamenti che devono essere creati in questo formato:

    <li><a href="http://site1.com">Site 1</a></li>
    <li><a href="http://site2.com">Site 2</a></li>
    <li><a href="http://site3.com">Site 3</a></li>

I blocchi piè di pagina possono essere in qualsiasi formato e possono essere utilizzati per salvare impronte Javascript, contenuto CSS o contenuto HTML personalizzato.

#### Gestire i distretti

Da questo menu è possibile creare i diversi distretti di un comune con il loro nome, coordinate, codice esterno e codice di censimento.

#### Fogli di firma

Per registrare il supporto esterno alla piattaforma, è possibile creare schede di firma di Proposte dei Cittadini o Progetti di Spesa inserendo l'ID della proposta in questione e inserendo i numeri dei documenti separati da virgole(,).

#### Statistica

Statistiche generali del sistema.

#### Impostazioni globali

Opzioni generali di configurazione del sistema.

### Pannello moderato

![Panel de moderación](imgs/panel_moderation.png?raw=true "Panel de moderación")

Da qui è possibile moderare il sistema, attraverso le seguenti azioni:

#### Proposte / Discussioni / Commenti

Quando un utente contrassegna in una proposta/dibattito/commento l'opzione "segnala come inappropriata", apparirà in questo elenco. Per quanto riguarda ciascuno di essi, appariranno il titolo, la data, il numero di reclami (quanti utenti diversi hanno controllato l'opzione di reclamo) e il testo della Proposta/Dibattito/Commento.

A destra di ogni elemento appare una casella che possiamo contrassegnare per selezionare tutti quelli che vogliamo dall'elenco. Una volta selezionati uno o più, troviamo alla fine della pagina tre pulsanti per eseguire azioni su di essi:

*   Nascondi: causerà l'interruzione della visualizzazione di tali elementi sul Web.
*   Blocca autori: farà sì che l'autore di quell'elemento smetta di poter accedere al web e che inoltre tutte le proposte / dibattiti / commenti di quell'utente smettano di essere mostrati sul web.
*   Segna come recensito quando consideriamo che tali elementi non dovrebbero essere moderati, che il loro contenuto è corretto e che quindi dovrebbero smettere di essere mostrati in questo elenco di elementi inappropriati.

Per facilitare la gestione, sopra troviamo un filtro con le sezioni:

*   In sospeso: Proposte/Dibattiti/Commenti che non sono ancora stati cliccati "nascondi", "blocca" o "segna come recensiti", e che quindi dovrebbero essere ancora rivisti.
*   Tutti: mostrando tutte le proposte/dibattiti/commenti sul sito web, e non solo quelli contrassegnati come inappropriati.
*   Contrassegnati come recensiti: quelli che qualche moderatore ha contrassegnato come recensiti e quindi sembrano corretti.

Si consiglia di rivedere regolarmente la sezione "in sospeso".

#### Blocca utenti

Un motore di ricerca ci consente di trovare qualsiasi utente inserendo il suo nome utente o e-mail e bloccarlo una volta trovato. Bloccandolo, l'utente non sarà in grado di accedere nuovamente al web e tutte le sue Proposte/ Dibattiti / Commenti saranno nascosti e non saranno più visibili sul web.

### Pannello di gestione

![Panel de gestión](imgs/panel_management.png?raw=true "Panel de gestión")

Da qui è possibile gestire gli utenti attraverso le seguenti azioni:

*   Gli utenti.
*   Modificare l'account utente.
*   Crea proposta.
*   Proposte di supporto.
*   Crea un progetto di spesa.
*   Sostenere progetti di spesa.
*   Stampa proposte.
*   Stampa progetti di spesa.
*   Inviti per gli utenti.

## Profili di valutatore e sedia da tavolo

### Pannello di valutazione

### Tavolo Sedie Pannello
