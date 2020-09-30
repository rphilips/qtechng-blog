---
title: "Deployment"
date: 2020-09-24T15:16:12+02:00
featured_image: "/images/deployment.svg"
---

Tijd om het *deployment scenario* te bespreken!

In de context van *deployment* wil `QtechNG` vooral streven naar **snelheid**: als we willen dat Brocade meermaals per jaar een productie release oplevert, dan moet de technische kant van het verhaal snel en correct verlopen.

Het kan niet zijn dat een 3-tal mensen een ganse dag bezig zijn met een release te installeren op een productieserver: stel dat we werken met maandelijkse sprints, dan is dit soort operatie gewoonweg veel te inefficiënt.

Daar komt dan nog eens bij dat er ook een andere ontwikkelrelease moet worden klaar gezet. Dit is heel wat minder belastend maar neemt - met de bestaande `qtech` - toch al gauw een 3-tal uur in beslag. Gedurende deze werkzaamheden kan er niet worden ontwikkeld.

Ik wil toch nog even vermelden dat werken met sprints, niet alleen een technisch verhaal is: de roadmap moet het ook mogelijk maken dat deze sprints kunnen worden opgeleverd.

Ik stel nu de volgende aanpak voor.

## Soorten machines

### B-machine

De `B-machine` (Beta-machine) is `dev.anet.be`. 

Alle ontwikkeling gebeurt daar op release `0.00`. `0.00` is niet langer meer een link maar bevat zowel source code als de versiecontrole (Deze zal in `QtechNG` niet langer gebaseerd zijn op `mercurial` maar op `git`). De versiecontrole wordt voortdurend *gepusht* naar `backup.anet.be`.

De registry waarde `qtechng-version` bevat de reële waarde van de versie (dit is nodig omdat deze waarde wordt gebruikt in de software: bijvoorbeeld in het werken met *guards* bij macro's en bij het vertalen van r4-waarden). De software wordt echter steeds opgehaald uit het repository onder `0.00`.


### W-machines

Op `W-machines` (werkstations) is de situatie ook eenvoudig:

- de registry waarde `qtechng-version` (de oude `qtech-version-development`) is steeds `0.00`.
- de registry waarde `qtechng-releases` bevat achteraan steeds `0.00` (vb. "5.00 5.10 0.00")


### P-machines

De software, die wordt geïnstalleerd op een P-machines (productie), wordt bepaald door de registry waarde `qtechng-version`.

Bestaat er een corresponderende versie in het repository op de `B-machine` dan wordt bij het synchroniseren deze versie gebruikt. 
Bestaat er **geen** corresponderende versie, dan wordt er gesynchroniseerd met `0.00`.

Nieuw is ook dat P-machines kunnen worden voorzien van een registry waarde `qtechng-backup`.


## Scenario

Om de gedachten te vestigen, laten we de toestand illustreren met een realistisch scenario. In het vervolg van de tekst werken we verder met dit voorbeeld.

```txt
Release `5.10` is afgerond en geïnstalleerd op `anet.be`. 

We zijn volop bezig met de ontwikkeling van `5.20`.

Op `dev.anet.be`:

- `qtechng-version` = `5.20`
- alle nieuwe code komt in `/library/software/0.00`
- er bestaat *GEEN* directory `/library/software/5.20`
- er bestaat *WEL* een directory `/library/software/5.10`

Op `anet.be`:

- `qtechng-version` = `5.10`
- `qtechng-backup` = `1`

Op werkstations:

- `qtechng-version` = `0.00`
- `qtechng-releases` = `5.00 5.10 0.00`
```

## Gedurende de ontwikkelfase

Een overzicht van de verschillende elementen die spelen tijdens de ontwikkelfase:

### W-machines

Business as usual.

### B-machine

- de source code in `0.00` wordt aangepast en uitgebreid
- de code uit `0.00` wordt voortdurend geïnstalleerd op de B-machine
- de source code in oudere releases wordt aangepast
- Hoewel `qtechng-version` = `5.20` bestaat er geen repository voor `5.20`
- De git database wordt voortdurend gepusht naar `backup.anet.be`

### P-machines

- werkt enkel met software corresponderend met `qtechng-version` (dit kan wel worden herleid naar `0.00` indien er geen passend repository bestaat op de B-machine)
- de P-machine kijkt naar de waarde van `qtechng-backup`. Is deze leeg of bestaat deze niet, dan stopt het verhaal.
  Is deze gelijk aan `1`, dan wordt het `0.00` repository van `dev.anet.be` voortdurend gesynchroniseerd (maar niet geïnstalleerd).
  Op deze wijze is er een voortdurende backup van de source code. Merk nog op dat het initiatief ook komt van `anet.be` (in tegenstelling tot de `push` naar de backup server).
  Dit `0.00` repository kan echter ook nog anders worden gebruikt (zie later)

## Installatie van een nieuwe release

### B-machine

Er hoeft niets te gebeuren!

### W-machines

Er hoeft niets te gebeuren!

### P-machine

- synchroniseren van release `0.00` uit `dev.anet.be` naar de P-machine: `qtechng release sync 0.00`
  Merk op, dat indien `qtechng-backup` = `1`, dit nagenoeg ogenblikkelijk verloopt. Brocade blijft operationeel gedurende deze fase.
- uitvoeren in release `5.10` van `/release/always/nextrelease.py`
- uitvoeren van Ansible uit release `0.00`
- `move` van `0.00` naar `5.20` in de lokale repositories: `qtechng release copy 0.00 5.20`
- installatie van `5.20`: `qtechng release install 5.20`

## Klaar zetten van een nieuwe ontwikkelrelease

### B-machine

- kopiëren van `0.00` naar `5.20`: `qtechng release copy 0.00 5.20`
- aanpassen van de registry waarde `qtechng-version` = `5.30`
- initialiseren van `/release/current` in `0.00`

### W-machines

- zet de registry waarde: `qtechng-releases` = `5.00 5.10 5.20 0.00`

### P-machines

Er hoeft niets te gebeuren!



## QtechNG versus Qtech

De essentie van dit verhaal gaat over procedure. Laten we er daarom van uitgaan dat `QtechNG` slechts een licht aangepaste versie is van `Qtech`.

Gewoon door de procedure wat aan te passen kan:

- de installatie van een nieuwe ontwikkelrelease nagenoeg ogenblikkelijk gebeuren. Ook de inspanningen op de individuele werkstations vallen weg.
- de installatie op een productiemachine kan worden herleid tot de helft van de inspanningen. Op `dev.anet.be` zijn er geen inspanningen meer nodig!
- tegelijkertijd een beter backup systeem opzetten (dat dan nog eens kan worden gebruikt bij de installatie zelf)


`QtechNG` is echter heel wat meer dan een *lichte* aanpassing van `Qtech`: door `Go` te gebruiken in plaats van `Python` en maximaal het `concurrency` model van `Go` aan te wenden, is deze software nog eens vele malen sneller.

Die 'helft' bij installatie op productiemachine gaat nog eens drastisch worden ingekort. Die software is nog volop in ontwikkeling.


## Opmerkingen

- deze opzet lijkt wat ingewikkeld maar is dat enkel zo bij eerste lezing: het verhoogt de kwaliteit van de backup en maakt optimaal gebruik van alle datastructuren
- het klaar zetten van een nieuwe ontwikkelrelease is werk van minuten (zowel op de B- als W-machines)
- het installeren op de productie machine wordt herleid tot het pure installeren van de software. Hier heeft `QtechNG` ruimschoots de gelegenheid om zich te bewijzen!
- als op een P-machine een andere versie moet worden geïnstalleerd dan `0.00` vervang dan in het voorgaande gewoon `0.00` door het passende versienummer.
- de `qtechng` instructies zijn zodanig geconstrueerd dat ze kunnen worden gebruikt in `procman`, **zonder** dat `procman` moet worden aangepast.
- Om een aantal collega's (1) te plezieren, komt er ook een registry waarde `qtechng-version-name`. Deze kan worden gebruikt om in het Brocade welkom scherm de release beter aan te duiden. Zo zou deze op `dev.anet.be` het woordje `beta` kunnen bevatten.

