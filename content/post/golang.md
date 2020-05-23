---
title: "Golang en QtechNG"
featured_image: "/images/golang.svg"
date: 2020-05-23T14:43:35+02:00
---

Elke nieuwe versie van `qtechng` werd gemaakt met een nieuwe technologie: Awk, Makefiles, C, Perl en Python passeerden de revue.

De Python versie - zowel de commandline interface (CLI) als de GUI - deden het heel erg goed.

Er moet dan wel een heel goede reden zijn om dit succesverhaal te stoppen en te opteren voor een andere oplossing.

Mijns inziens zijn er diverse redenenen.

## Opstarttijd

Een eerste reden ligt in de opstarttijd van de huidige `CLI`. Nu zal je zeggen, veel last heb ik daar nog niet van ondervonden!

Dat klopt, maar dat komt omdat de huidige Python toepassingen niet zo dikwijls worden opgestart: de GUI wordt meestal slechts 1x opgestart en maakt dan intern gebruikt van de beschikbare API's. De nieuwe - op Visual Studio Code gebaseerde - oplossing start wel degelijk de API zelf op en er is een merkbare vertraging. Daar komt bij dat de huidige `CLI` in `Python2` werd vervaardigd. `Python3` heeft een merkbare tragere opstart. Brocade's nieuwe toolcat framewerk gaat daar ook niet veel aan helpen!

Go code komt in één enkel executable en heeft een veel beter opstarttijd: er komt geen interpreter aan te pas en er hoeven ook niet meerder source bestanden worden opgestart (naargelang de setup van de Python installatie kunnen dat 10-tallen scripts zijn). Deze vraag naar betere opstart dan Python3 kan leveren, komt niet alleen uit `qtechng`: ook projecten als Mercurial en Firefox noteren het probleem.

Je zou kunnen argumenteren dat we de techniek van `wxqtech` kunnen imiteren en maar moeten gebruik maken van de `API`. Dat is toch heel wat moeilijker: bijvoorbeeld Visual Studio Code is zelf niet geprogrammeerd in `Python`. Bijgevolg moeten er tussenoplossing gezocht worden in een client/server model. Dit gaat de bedrijfszekerheid, laat staan de installeerbaarheid, niet ten goede komen.

Daarmee komen we aan een de volgende reden.

## Installeerbaarheid

`qtechng` is een instrument dat niet alleen voor ontwikkelaars moet werken. 

Om de een check-out met de huidige `qtech` te kunnen doen met eerste de juiste versie van `Python` worden geïnstalleerd. Vervolgens moet een SSH cliënt worden opgezet. Met `scp` (of een gelijkaardige software) moeten dan handmatig een 5-tal Brocade projecten worden getransfereerd vanop de goede plaats. Deze moeten dan zorgvuldig worden geïnstalleerd en, als de passende environment variabelen zijn gezet, kunnen we aan de slag.

Zelfs ontwikkelaars verliezen hierbij gemakkelijk hun weg.

Met `go` is het mogelijk om een executable in het `PATH` te plaatsen en men kan aan de slag.

De mogelijkheid om fout te gaan is gewoon vele malen kleiner: gedaan met reeds geïnstalleerde *systeem pythons*, oude versie van python, niet goed afgestelde systeem registry, dubbel python versies, afstellen van `PYTHONPATH` zodat zowel `python2` als `python3` kunnen werken.

## Ingebouwde SSH

Er bestaan effectief SSH libraries in Python, deze zijn echter weinig efficiënt en werken moeilijk samen met een bestaande SSH infrastructuur (zoals aanwezige private/public keys en `ssh-agents`). In `qtech` zag ik me genoodzaakt om beroep te doen op de `ssh` en `scp` clients van het platform wat opnieuw vertragingen meebracht.

`Go` komt met een state-of-the-art implementatie van het `SSH` protocol: de communicatie gaat merkbaar sneller en bovendien kan deze perfect samenwerken met de gegeven SSH infrastructuur.

De implementatie speelt perfect in op het standaard reader/writer mechanisme van de programmeertaal.

## CLI framewerk

Met [Cobra](https://github.com/spf13/cobra "Cobra") beschikt `Go` over het perfect framewerk om POSIX-compliant toepassingen te maken met alles er op en er aan:

- Commando's en sub-commando's
- Interactieve design met Viper
- Automatische help en documentatie (o.a in `reStucturedText`)
- `Bash autocomplete` ondersteuning

Eens de `CLI` aangemaakt, is de executable onafhankelijk van Cobra of Viper

## Snelheid van uitvoering

Een executable, gebaseerd op Go, werkt snel: daar is de compilatie verantwoordelijk voor.

Echter er zijn ook andere redenen: de ingebouwde Go libraries zijn exceptioneel. Google heeft kosten nog moeite gespaard om kwaliteit te leveren.

Toch ligt de voornaamste reden in de snelheidswinst in de mogelijkheden om, op gemakkelijke wijze, softwarecomponenten *concurrent* uit te voeren. Zeker in `I/O` gevoelige toepassing als `qtechng` kan hier grote winsten worden geboekt: eerste testen tonen 20-voudige snelheidswinst aan ten opzichte van de `Python` versie.

Deze snelheidswinst is niet alleen van belang bij interactieve operaties maar is ook van groot belang bij operaties zoals [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration "CI"), zeg maar de `sweep`. 

Ook het installatie proces van een nieuwe Brocade release zou op deze wijze drastisch kunnen worden herleid. Dit is zeker van belang als we van plan zijn meerdere, tussentijdse, releases te gaan voeren.

## Descriptieve software componenten

Deze snelheidswinst hoeft echter niet helemaal te gaan naar snelheid van uitvoering: een gedeelte kan ook besteed worden om bepaalde componenten van `qtechng` eerder descriptief aan te pakken dan manueel - en dus (meestal) sneller - te implementeren.

Ik geef twee voorbeelden om dit in het licht te zetten.

De configuratie bestanden `brocade.json` is duidelijk veel complexer (en ook veel krachtiger) dan in vorige versie. Door de structuur rigoureus te beschrijven via een `JSON schema` kan validatie en implementatie software ook automatisch worden gegenereerd. Go leent zich heel goed tot dergelijke operaties.

Een ander voorbeeld is bijvoorbeeld de macro structuur. Macro's zijn heel erg belangrijk voor `qtechng`: het zijn de API's waarrond alles draait. In `qtechng` winnen macro's in belangrijke mate aan kracht. In plaats van een handmatige parser te schrijven kan nu de kracht van een [PEG-parser](https://en.wikipedia.org/wiki/Parsing_expression_grammar "PEG-parser") worden aangewend. Ja, deze parsers geven minder efficiënte code, maar ze geven meteen ook een rigoureuze definitie van het macro systeem. Iets waar Brocade al langer nood aan heeft.







