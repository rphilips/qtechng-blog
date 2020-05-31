---
title: "Version"
featured_image: "/images/version.svg"
date: 2020-05-22T10:00:23+02:00
---

Voor software projecten die lang bestaan in de versie aanduiding belangrijk.

De communicatie rond de mogelijkheden van een software, worden gevoerd rond deze versie aanduiding.
Release notes zijn bijvoorbeeld gecentreerd rondom een versie.

Niet zelden vinden versie aanduidingen hun weg naar contacten. Dat kan verschillende vormen aannemen: verplichtingen die gelden tot een versie (dit impliceert meteen dat er een zekere ordening bestaat in de versie aanduidingen), of het aantal releases die worden opgeleverd in een gegeven tijdspanne.

In Brocade hebben we sinds 2000 de gewoonte aangenomen om het versienummer te schrijven als `[0-9]+\.[0-9][0-9]`. De betekenis van deze nummer is vrij eenvoudig: de tweede numerieke component wordt bij elke release (ongeveer jaarlijks) met `10` verhoogd. Dit verhogen met `10` biedt de mogelijkheid om - voor administratieve reden - tussen releases te kunnen definieren.

De eerste component verhogen is eerder een kwestie van opportunisme: bijvoorbeeld we zijn overgeschakeld van `4` naar `5` om de breuk in een contractuele verplichting duidelijk in de verf te zetten.

Een tijd - ondertussen een paar jaar - geleden hadden Luc en ik een discussie over het gebruik van *Semantic Versioning".

## Semantic versioning

De discussie die Luc en ik voerden, startte over de betekenis van een projectnummer van de gedaan `0.98.12`. Het gebruik van een software waarvan het versie nummer begint met `0.` is niet erg geruststellend: meestal duidt dit op een `beta` versie, nauwelijks beproefd in `the wild`. Maar eerlijk gezegd, dat slaat nergens op: de betekenis van die nummertjes ligt immers niet vast.

Is deze software een eindpunt op zich - bijvoorbeeld een tekstverwerker - dan is dat geen probleem: je gebruikt immers de software of je gebruikt hem niet en daar stopt het.

Wordt de software echter een bouwsteen van je eigen software (bijvoorbeeld: [Lucene](https://en.wikipedia.org/wiki/Apache_Lucene "Lucene")), dan wordt dit een ander paar mouwen. Er zijn immers dan 2 software projecten - het jouwe en Lucene - die onafhankelijk van elkaar evolueren. Als je Lucene wil gebruiken en er komt een nieuwe versie aan, dan wil je echt wel goed weten welke inpact dat deze software heeft op Brocade.

Maar, eerlijk gezegd, ook dat is best goed beheersbaar: Luc en Marc, kennen de twee software door en door, installeren *eventueel* en doen de nodige incompatibiliteitsaanpassingen.

Er is echter nog een ander probleem: ik noem dat graag het probleem van de kleine componenten.

Moderne software maakt graag gebruik van de inspanningen elders. Ik geef daar meteen een voorbeeld van in `qtechng`.

`qtechng` is een software project geschreven in [Go](https://en.wikipedia.org/wiki/Go_(programming_language) "Golang")

Op dit ogenblik zijn er reeds tal van *vreemde* projecten - buiten het package systeem van Golang zelf - die worden gebruikt:

- github.com/natefinch/atomis: Op atomische wijze wgeschrijven van data
- github.com/xanzy/ssh-agent: Het gebruik van ssh-agent in go
- github.com/atotto/clipboard: OS onafhankelijk omgaan van clipboard data in go
- github.com/spf13/afero: Virtuele filesystemen in go
- github.com/spf13/cobra: Toolcat-achtig framewerk in go

Deze *vreemde* projecten worden zelf ook gebouwd uit andere componenten, en dan weer ...

Elk van deze deelcomponenten worden aangepast en hebben rechtstreeks invloed op de goede werking van je software.

Hier komt nog bij dat je software de deelcomponenten ook *automatisch* kan updaten (zie je het verschil met lucene ?)

Welkom in *dependency hell* !

[Semantic Versioning](https://semver.org/ "SemVer") is een initiatief uit de software industrie die tracht om precies dit probleem aan te pakken.

In dit nummerschema wordt betekenis gegeven aan de diverse componenten: `Major.Minor.Patch`

- Major: verandering van deze component houdt een hoog risico in. Functionaliteit verandert.
- Minor: verandering van deze component houdt een miniem risico in. Bijvoorbeeld de signatuur van de API krijgt een argument bij.
- Patch: verandering van deze component houdt een klein risico in. Meestal een eenvoudige bugfix.

Sommige ontwikkelsystemen (zoals vb. Go) gaan hier op uiterste gesofistikeerde manier mee om: het module systeem gebruikt die 3 componenten en gaat bijvoorbeeld wel automatische updates toelaten van `Patch`.
De rest moet expliciet worden geconfigureerd.

Niet alle software projecten gaan hier even gezwind mee om of gaan hier licht van afwijken (vb. [Python](https://www.python.org/dev/peps/pep-0440/ "Version Identification and Dependency Specification") )

Ik denk dat Semantic Versioning zijn plaats heeft in Brocade: niet zozeer om de bestaande versie aanduiding te vervangen maar wel om deelcomponenten zoals `toolcat`, `clib` e.d. te specificeren.

Versie aanduidingen hebben zeker een rol te spelen in het verwante *versie controle*.

Maar dat is een onderwerp voor een ander blog post.
