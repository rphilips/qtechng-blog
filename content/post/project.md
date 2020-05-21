---
title: "Projecten"
featured_image: "/images/project.svg"
date: 2020-05-19T08:59:12+02:00
---

## Projecten: een stand van zaken

Brocade 5.00 telt meer dan 14000 bestanden.

Om beheer mogelijk te maken, moet hier structuur worden aangebracht. Het voornaamste structuurelement is het *project*. 
Een project staat voor een deelverzameling van deze bestanden, fysiek ondergebracht in een directory.

Van oudsher kent Brocade een thematische opsplitsing: zo werden bestanden rondom het bestellen van dingen gegroepeerd in projecten met namen als:
`/requests/impala`, `/requests/repository`, `/requests/virlib`. Deze werden dan aangevuld met minder voor de hand liggende projecten zoals `/requests/admin`, `/requests/gateway`, ...

Deze projecten hebben gemeen dat ze gaan over het bestellen van artefacten uit de bibliotheekwereled, met alles wat daarbij komt kijken.
Niet zelden is er een hoofdontwikkelaar die gaat over deze projecten. Kennis en creativiteit vergaren is immers dikwijls een werk van jaren.

De meeste projecten in Brocade 5.00 hebben 2 componenten (vb. "requests" en "virlib"). Dat komt gewoon zo goed uit en is zeker geen verplichting. In `qtech` kan een project nooit een directory bevatten: enkel bestanden zijn welkom.

Er zijn ook andere organisatievormen mogelijk dan de thematische. Er zijn reeds voorstellen gedaan om de projecten op te splitsen naar de gebruikte technologie: sommige projecten zijn in `python2`, andere in `python3` of `mumps`.

Indeling naar technologie heeft grote voordelen voor het ontwikkelproces. Anderzijds zijn de meeste projecten heterogeen: `Mumps`, `Python`, `reStructuredText` ... ze komen dikwijls samen voor.

`qtech` had hiervoor een oplossing met `properties`: files en projecten konden worden gelabeld en, op basis van deze labels, worden uitgecheckt/ingecheckt/verwerkt. Er was zelf een bestandstype (`*.q` files) waarmee eigenschappen *automatisch* konden worden toegekend.

In die kleine 20 jaar dat `qtech` in gebruik was, ben ik ongeveer de enige die deze feature heeft gebruikt. Overigens, met weinig succes!


In `qtechng` wordt de definitie van een project aangescherpt. 

## QtechNG: projecten kunnen directories bevatten

Moderne software projecten komen in een directory tree. Node, Go, Hugo, reStructuredText ... noem maar op: ze kennen allemaal het concept van project en ze zijn in boom-vorm. 
Dikwijls gaat de ondersteunende software hier ook handig op inspelen.

Als dergelijke projecten een plaats moeten krijgen binnen `qtechng`, dan moet deze boomstructuur ook kunnen.

## QtechNG: projecten kunnen kind-projecten bevatten

`qtechng` gaat nog verder: projecten kunnen ook kind-projecten bevatten. 

Dit heeft grote implicaties (en ook grote mogelijkheden) over de installatie van een project op een systeem.

In een latere blog post gaan we dit uitvoerig bespreken.

## brocade.json

Elk project moet in zijn root-directory het bestand `brocade.json` bevatten. Dit bestand vervangt de vroegere `install.cfg`. 
Er werd een andere naam gekozen omdat het dan voor bijvoorbeeld Visual Studio Code onmiddellijk duidelijk was hoe dergelijke bestanden moesten worden bewerkt.

In tegenstelling tot `install.cfg`, is `brocade.json` verplicht! Het aantal mogelijkheden is ook drastisch uitgebreid.

## Andere bestanden

Projecten komen nog met andere *standaard* bestanden: 

- install.py: help bij de installatie van het project op een server
- release.py: help bij het opzetten van allerlei registry waarden
- check.py: voert diverse controles uit die passen bij de installatie van het project
- local.py: wordt enkel uitgevoerd op werkstations

Later zullen we deze bestanden in meer detail bespreken.
