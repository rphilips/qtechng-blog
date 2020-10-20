---
title: "CLI structure"
date: 2020-10-20T11:54:54+02:00
featured_image: "/images/clistructure.svg"
---

Laten we even stil staan bij de werking van de `QtechNG CLI`.

Een typische invocatie is:

<div>qtechng <span style="color:blue;">project</span> <span style="color:red;">co</span> <span style="color:green;">/core/python3</span> <span style="color:brown;">--version=6.00 --tree</span></div>




Er zijn essentieel 5 onderdelen.


## Executable

De werknaam is `qtechng`. Dit kan echter nog veranderen.

## Het onderwerp

Dit bevat het soort object waarover het commando gaat.

Op dit ogenblik hebben we de volgende onderwerpen:

- `clipboard`: acties in verband met het clipboard
- `file`: acties in verband met lokale bestanden
- `project`: acties in verband met QtechNG projecten
- `registry`: acties in verband met de registry
- `source`: acties in verband met bestanden in het repository
- `stdin`: acties in verband met stdin
- `system`: acties in verband met systeemconfiguratie
- `tempdir`: acties in verband met tijdelijke mappen
- `version`: acties in verband met de versie

`QtechNG` verzamelt ook eenvoudige instrumenten die het maken van scripts simpelder maken.

Met `qtechng help` kan je de onderwerpen oplijsten.


## Het werkwoord

Bij het onderwerp `project` zijn er de volgende werkwoorden gedefinieerd:

- `co`: checkout van een project
- `delete`: schrappen van een project
- `info`: informatie over een project
- `list`: oplijsten van de inhoud
- `new`: aanmaak van een nieuw project
- `rename`: hernoemen van een project

Elk onderwerp heeft zijn eigen werkwoorden.

Met `qtechng project help` kan je de werkwoorden bij `project` oplijsten.

## De argumenten

Argumenten kunnen verplicht, verbode, enkelvoudig of meervoudig zijn.

Indien er argumenten zijn, zijn deze steeds van het type passend bij het onderwerp.


## Vlaggen

Vlaggen dienen om de werking te verfijnen of om meer informatie te geven.

Vlaggen kunnen *overall* werken:

- uid: User ID
- stdout: Filename containing the result
- cwd: Working directory
- unhex: Unhexify the arguments starting with `.`
- editor: editor name (vb. vscode)
- jsonpath: JSONpath
- quiet: Silence the output

of per *onderwerp*:

vb. bij `system` bestaat de vlag `--remote`

- `qtechng system` vraagt informatie op van de actuele computer
- `qtechng system --remote` vraagt informatie op van `dev.anet.be`


of per *werkwoord*:

vb. bij `source` bestaan de vlaggen:

- version: Version to work with
- tree: Files with hierarchy intact
- auto: Automatic files according to the registry
- nature: QtechNG nature of file
- cuser: UID of creator
- muser: UID of last modifier
- cbefore: Created before
- cafter: Created after
- mbefore: Modified before
- mafter: Modified after
- needle: Find substring
- pattern: Posix glob pattern
- neighbours: Indicate if all files in project are selected
- qdir: QPath of a directory under a project
- perline: Searches per line
- recurse: Recursively walks through directory and subdirectories
- regexp: Searches as a regular expression
- tolower: Transforms to lowercase
- smartcaseoff: Forbids smartcase transformation


## Ook nog

De qtechng CLI wordt relatief weinig *zichtbaar* gebruikt: hij zit verborgen in toepassingen zoals *Vscode*

Er zijn ook shortcuts mogelijk: gebruik de `alias` features van je geprefereerde shell. 

`QtechNG` kan je ook informatie verschaffen omtrent je bestanden:



```bash

$ qtechng file tell cat.d
{
    "host": "richard-xps13",
    "time": "2020-10-20T15:43:40+02:00",
    "ERROR": null,
    "RESULT": {
        "abspath": "/home/rphilips/tmp/work/catalografie/application/cat.d",
        "basename": "cat.d",
        "dirname": "/home/rphilips/tmp/work/catalografie/application",
        "ext": ".d",
        "project": "/catalografie/application",
        "python": "",
        "qpath": "/catalografie/application/cat.d",
        "relpath": "cat.d",
        "version": "6.00"
    }
}
```

```bash

$ qtechng file tell cat.d --tell=project
/catalografie/application$ 

```


```bash

$ export PROJECT=`qtechng file tell cat.d --tell=project`
$ echo $PROJECT
/catalografie/application

```











    



