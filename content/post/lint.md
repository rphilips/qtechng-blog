---
title: "Linter"
date: 2020-08-02T13:23:14+02:00
featured_image: "/images/lint.svg"
---

*Linters* zijn een belangrijke onderdeel van *QtechNG*.

Een linter onderzoekt source code en meldt indien er iets schort aan de software. Er zijn zijn essentieel twee soorten berichten:

- De code is onwerkbaar: hij beantwoordt niet aan de vereisten van de specificatie
- De code is werkbaar maar is samengesteld tegen de afspraken in: de stijl van de software past niet.

*Brocade* werkt met een grote verscheidenheid aan specificaties: behalve aan goed gekende structuren (HTML, JSON, Python, reST, ...) zijn er ook minder gekende specificaties zoals M en interne formaten zoals X-files, D-files, L-files, B-files, I-files en M-files.

*QtechNG* houdt zich met deze laatsten bezig.

In de eerste versie van *QtechNG* worden linters vervaardigd voor D-files, L-files en I-files. Dit is niet toevallig: deze bestanden definiëren *objecten* (`macro`, `inlude` en `lgcode`). De controle gebeurt op drie niveaus.

Op het **eerste niveau** worden de bestanden zelf onderzocht:

- zijn ze voorzien van een overkoepelend commentaarveld ?
- zijn ze in *UTF-8* ?
- Beantwoorden ze aan de passende `PEG`-specificatie ?
- zijn de gegenereerde objecten uniek binnen de file ?

Cruciaal is het afchecken tegen de `PEG`-specificatie. In deze blog heb ik het al gehad over `PEG` in Go en de gegeneerde software met `Pigeon`. Pas indien de bestanden aan de specificatie voldoen, kunnen macros, includes en lgcodes worden geconstrueerd.

Dan kan het **tweede niveau** van linten beginnen: linten op het niveau van het object. Hier worden allerlei elementen van de diverse objecten onderzocht. Dit zijn dingen die zich niet lenen tot het linten of file niveau (vb.: het onderzoeken van documentatie rekening houdend met standaarddocumentatie)

Het **derde niveau** verlaat het pure file niveau en gaat controles uitvoeren tegenover het *repository*:

- Zijn de objecten ook uniek in het repository ? 
- Worden nog in gebruik zijnde objecten geschrapt ?

Het was belangrijk dat deze linters eerst klaar waren: vooraleer er naar *QtechNG* kan worden gemigreerd, moeten de bestaande objectfiles worden gecontroleerd op hun geldigheid. 
Fouten moeten manueel worden gecorrigeerd.
Werk aan de winkel!
