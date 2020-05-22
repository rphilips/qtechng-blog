---
title: "Configuratie bestand"
date: 2020-05-21T10:30:43+02:00
featured_image: "/images/config.svg"
---

Elk `qtechng` project komt met een uniek configuratiebestand. Dit bestand bevindt zich steeds in de root-directory van het project en heeft een vaste naam `brocade.json`. (m.a.w. de `qtechng` path-naam van de configuratie file is steeds de `qtechng` path-naam van het project, aangevuld met `brocade.json`)

Dit bestand is een *JSON* bestand dat gestructureerd is volgens het schema [qtechng.schema.json](https://dev.anet.be/brocade/schema/qtechng.schema.json "JSON schema voor brocade.json").

Dit heeft zo zijn voordelen: Visual Studio Code kan gebruik maken van deze specificatie om te helpen bij het editeren.

Er zijn nog andere voordelen maar daar vertellen we over als we het hebben over het gebruik van *Go* als implementatie taal.

Hou er mee rekening dat `brocade.json` het enige bestand is dat **NIET** wordt ingecheckt in het software repository als `qtechng` een fout merkt in het bestand.



`brocade.json` kan je opsplitsen in 2 delen:

- Richtlijnen voor installatie

- Specificatie en afhandeling van de bestanden in het project.


## Voorbeeld

Het volgende voorbeeld toont een eenvoudig `brocade.json` bestand. 

Let op het `$schema` attribuut: het vertelt de editor welk schema er van toepassing is.
In Visual Studio Code is er meteen uitgebreide documentatie en ondersteuning van het editeer-proces.

```json
    {
        "$schema": "https://dev.anet.be/brocade/schema/qtechng.schema.json",
        "core": true,
        "mumps": [
            "gtm"
        ],
        "py3": true,
        "binary": [
            "*.zip"
        ]
    }
```

## Richtlijnen voor installatie

De attributen "passive", "mumps", "groups", "names", "roles", "versionlower", "versionupper" helpen uit te maken of het project moet worden geïnstalleerd. Deze waarden worden vergeleken met registry waarden op de actuele server.

"py3", "core", "priority" hebben geen impact of het project moet worden geïnstalleerd, maar beïnvloeden wel het installatieproces.

Meteen een gouden regel voor de installatie van kind-projecten: een kind-project kan enkel worden geïnstalleerd als *ALL* ouder-projecten ook zijn geïnstalleerd.

Dit betekent nog dat "core" weinig zin heeft voor een kind-project. "priority" is relatief onder de kind-projecten van dezelfde ouder.


## Specificatie en afhandeling van de bestanden

In `QtechNG` ken het *speciaal* statuut van bestanden worden weggenomen. Bij voorbeeld kan worden vastgelegd dat `helloworld.d` geen bestand is met macro's (maar vb. een programma in `dlang`).

Zeer handig is ook de specificatie van wat *binary* is.

Hou er mee rekening dat deze specificaties steeds komen als *glob patterns* (met forward slashes) tegenover het relatieve path binnen het project.




## Overzicht van de attributen

Let er op: alle attributen zijn in *lowercase*


### binary
- `type`: *array*
- `description`: De bestanden uit het project waarbij de relatieve `qtechpath` overeenkomt met 1 van de elementen van de array, worden als `binary` bestand beschouwd. Er gebeurt geen r4/i4/m4/l4 substitutie. Deze waarde wordt *NIET* overgenomen in kind-projecten.
- `default`: []
- `uniqueItems`: True
- `items`:
  - type: string
  - description: Een wildcard voorstelling op de relatieve `qtechpath` naam van bestanden (dit is relatief ten opzichte van het project).

### core
- `type`: *boolean*
- `description`: Indien `true`, dan wordt dit project geïnstalleerd samen met andere core projecten. Deze waarde specificeren binnen kind-projecten heeft geen effect. Indien `true`, dan zijn alle kind-projecten, core projecten.
- `default`: false

### emptydirs
- `type`: *array*
- `description`: De bestanden uit het project waarbij de relatieve `qtechpath` overeenkomen met 1 van de elementen van de array, wordt als directories beschouwd. Deze worden op werkstations aangemaakt, ook als ze geen bestanden bevatten. Deze waarde wordt *NIET* overgenomen in kind-projecten.
- `default`: []
- `uniqueItems`: True
- `items`:
  - type: string
  - description: Een wildcard voorstelling op de relatieve `qtechpath` naam van bestanden (dit is relatief ten opzichte van het project).

### groups
- `type`: *array*
- `description`: Dit project wordt enkel geïnstalleerd als 1 van de array elementen overeenkomt met de registry waarde `system-group`. Bij niet-installatie, worden ook de kind-projecten *niet* geïnstalleerd.
- `default`: ["*"]
- `uniqueItems`: True
- `items`:
  - type: string
  - description: Een wildcard voorstelling voor de registry waarde `system-group`.

### i4binary
- `type`: *array*
- `description`: De bestanden uit het project waarbij de relatieve `qtechpath` overeenkomen met 1 van de elementen van de array, wordt als `i4binary` bestand beschouwd. Er gebeurt geen i4 substitutie. Deze waarde wordt *NIET* overgenomen in kind-projecten.
- `default`: []
- `uniqueItems`: True
- `items`:
  - type: string
  - description: Een wildcard voorstelling op de relatieve `qtechpath` naam van bestanden (dit is relatief ten opzichte van het project).

### i4noterror
- `type`: *array*
- `description`: *qtechng* gaat een fout genereren indien een i4 waarde voorkomt in een bestand terwijl deze i4 waarde niet gedfinieerd is. Dit *i4noterror* laat toe om uitzonderingen hierop te specificeren: voeg een koppel toe aan de array met als eerste element de bewuste i4 waarde en als tweede element een wildcard dat matcht aan het bestand.
- `default`: []
- `uniqueItems`: True
- `items`:
  - type: array
  - description: Een array met twee elementen: het eerste element is een i4-string, het tweede element is een wildcard voorstelling op de relatieve `qtechpath` naam van bestanden (dit is relatief ten opzichte van het project).

### l4binary
- `type`: *array*
- `description`: De bestanden uit het project waarbij de relatieve `qtechpath` overeenkomen met 1 van de elementen van de array, wordt als `l4binary` bestand beschouwd. Er gebeurt geen l4 substitutie. Deze waarde wordt *NIET* overgenomen in kind-projecten.
- `default`: []
- `uniqueItems`: True
- `items`:
  - type: string
  - description: Een wildcard voorstelling op de relatieve `qtechpath` naam van bestanden (dit is relatief ten opzichte van het project).

### l4noterror
- `type`: *array*
- `description`: *qtechng* gaat een fout genereren indien een l4 waarde voorkomt in een bestand terwijl deze l4 waarde niet gedfinieerd is. Dit *l4noterror* laat toe om uitzonderingen hierop te specificeren: voeg een koppel toe aan de array met als eerste element de bewuste l4 waarde en als tweede element een wildcard dat matcht aan het bestand.
- `default`: []
- `uniqueItems`: True
- `items`:
  - type: array
  - description: Een array met twee elementen: het eerste element is een l4-string, het tweede element is een wildcard voorstelling op de relatieve `qtechpath` naam van bestanden (dit is relatief ten opzichte van het project).

### m4binary
- `type`: *array*
- `description`: De bestanden uit het project waarbij de relatieve `qtechpath` overeenkomen met 1 van de elementen van de array, wordt als `m4binary` bestand beschouwd. Er gebeurt geen m4 substitutie. Deze waarde wordt *NIET* overgenomen in kind-projecten.
- `default`: []
- `uniqueItems`: True
- `items`:
  - type: string
  - description: Een wildcard voorstelling op de relatieve `qtechpath` naam van bestanden (dit is relatief ten opzichte van het project).

### m4noterror
- `type`: *array*
- `description`: *qtechng* gaat een fout genereren indien een m4 waarde voorkomt in een bestand terwijl deze m4 waarde niet gedfinieerd is. Dit *m4noterror* laat toe om uitzonderingen hierop te specificeren: voeg een koppel toe aan de array met als eerste element de bewuste m4 waarde en als tweede element een wildcard dat matcht aan het bestand.
- `default`: []
- `uniqueItems`: True
- `items`:
  - type: array
  - description: Een array met twee elementen: het eerste element is een m4-string, het tweede element is een wildcard voorstelling op de relatieve `qtechpath` naam van bestanden (dit is relatief ten opzichte van het project).

### mumps
- `type`: *array*
- `description`: Dit project wordt enkel geïnstalleerd als de registry waarde `m-os-type` in `mumps` voorkomt. Bij niet-installatie, worden ook de kind-projecten *niet* geïnstalleerd.
- `default`: ["gtm", "cache", ""]
- `uniqueItems`: True
- `items`:
  - type: string
  - description: Identifier voor de M versie op het target systeem.
  - enum: ['gtm', 'cache', '']

### names
- `type`: *array*
- `description`: Dit project wordt enkel geïnstalleerd als 1 van de array elementen overeenkomt met de registry waarde `system-name`. Bij niet-installatie, worden ook de kind-projecten *niet* geïnstalleerd.
- `default`: ["*"]
- `uniqueItems`: True
- `items`:
  - type: string
  - description: Een wildcard voorstelling voor de registry waarde `system-name`.

### notbrocade
- `type`: *array*
- `description`: De bestanden uit het project waarbij de relatieve `qtechpath` overeenkomt met 1 van de elementen van de array, worden niet als een `*.[bdilmx]` file beschouwd. Deze waarde wordt *NIET* overgenomen in de kind-projecten.
- `default`: []
- `uniqueItems`: True
- `items`:
  - type: string
  - description: Een wildcard voorstelling op de relatieve `qtechpath` naam van bestanden (dit is relatief ten opzichte van het project).

### notconfig
- `type`: *array*
- `description`: De bestanden uit het project waarbij de relatieve `qtechpath` overeenkomt met 1 van de elementen van de array, worden niet als een Brocade configuratie file (brocade.json) beschouwd. Deze waarde wordt *NIET* overgenomen in de kind-projecten.
- `default`: []
- `uniqueItems`: True
- `items`:
  - type: string
  - description: Een wildcard voorstelling op de relatieve `qtechpath` naam van bestanden (dit is relatief ten opzichte van het project).

### passive
- `type`: *boolean*
- `description`: De waarde `true` zorgt ervoor dat het project *niet* wordt geïnstalleerd. Bij niet-installatie, worden ook de kind-projecten *niet* geïnstalleerd.
- `default`: false

### priority
- `type`: *number*
- `description`: Geeft binnen de 2 groepen, core en niet-core, wat de volgorde is van installatie: hoge prioriteit wordt eerder geïnstalleerd. Kind-projecten worden altijd geïnstalleerd binnen hun ouder (in volgorde van prioriteit)
- `default`: 10000

### py3
- `type`: *boolean*
- `description`: Indien `true`, dan worden install.py/check.py/local.py/release.py met `python3` uitgevoerd, zoniet met python2. Deze waarde wordt *NIET* overgenomen in kind-projecten.
- `default`: false

### r4binary
- `type`: *array*
- `description`: De bestanden uit het project waarbij de relatieve `qtechpath` overeenkomt met 1 van de elementen van de array, worden als `r4binary` bestand beschouwd. Er gebeurt geen r4 substitutie. Deze waarde wordt *NIET* overgenomen in kind-projecten.
- `default`: []
- `uniqueItems`: True
- `items`:
  - type: string
  - description: Een wildcard voorstelling op de relatieve `qtechpath` naam van bestanden (dit is relatief ten opzichte van het project).

### r4noterror
- `type`: *array*
- `description`: *qtechng* gaat een fout genereren indien een r4 waarde voorkomt in een bestand terwijl deze r4 waarde niet gedfinieerd is. Dit *r4noterror* laat toe om uitzonderingen hierop te specificeren: voeg een koppel toe aan de array met als eerste element de bewuste r4 waarde en als tweede element een wildcard dat matcht aan het bestand.
- `default`: []
- `uniqueItems`: True
- `items`:
  - type: array
  - description: Een array met twee elementen: het eerste element is een r4-string, het tweede element is een wildcard voorstelling op de relatieve `qtechpath` naam van bestanden (dit is relatief ten opzichte van het project).

### roles
- `type`: *array*
- `description`: Dit project wordt enkel geïnstalleerd als *alle* rollen uit de registry waarde `system-roles` overeenkomen met minstens 1 element van de array. Bij niet-installatie, worden ook de kind-projecten *niet* geïnstalleerd.
- `default`: ["*"]
- `uniqueItems`: True
- `items`:
  - type: string
  - description: Een wildcard voorstelling voor de registry waarde `system-roles`.

### versionlower
- `type`: *string*
- `description`: Dit project wordt enkel geïnstalleerd als de registry waarde `brocade-release` lexicografisch kleiner is dan deze waarde. Bij niet-installatie, worden ook de kind-projecten *niet* geïnstalleerd.
- `default`: "~"

### versionupper
- `type`: *string*
- `description`: Dit project wordt enkel geïnstalleerd als de registry waarde `brocade-release` lexicografisch groter is dan deze waarde. Bij niet-installatie, worden ook de kind-projecten *niet* geïnstalleerd.
- `default`: ""