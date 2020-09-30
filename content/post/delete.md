---
title: "Delete"
date: 2020-09-30T17:04:58+02:00
featured_image: "/images/delete.svg"
---

Het schrappen van een bestand in `QtechNG` ?

Hoe moeilijk kan dat zijn ?

Wel, laten we stellen dat het een orde moeilijker is dan het opslaan van een bestand in `QtechNG`.

## Probleem 1: Schrappen ? Wat betekent dit precies ?

Elk bestand in `QtechNG` is gekenmerkt door een `qpath`.

Dergelijk `qpath` leidt, binnen een gegeven release, tot een plaats in het fileystem. 
Dit bestand moet worden verwijderd.

Een bestand komt ook met `uniqueness` informatie voor de `basename`.
Vanzelfsprekend hoeft niet elke `basename` uniek te zijn: op dit ogenblik wordt dit enkel bekrachtigd voor basenames met een extensie in de registry waarde voor `qtechng-unique-ext`. Daar staan nu enkel `x-files` en `m-files` in.

De benodigde informatie om dit te controleren, wordt echter wel weggeschreven: deze registry waarde kan immers zo veranderen.

Elk bestand in `QtechNG` komt ook met meta informatie. Ook deze moet worden opgeruimd.

Dit proces wordt gelukkig geharmoniseerd door gebruik te maken van virtuele filesystemen.

## Probleem 2: Wanneer is schrappen toegelaten ?

Mensen, dit is het *echte* probleem.

Geven we een overzicht:

- Het schrappen van een `brocade.json` file mag enkel indien het de laatste file is in het corresponderende project.

- `binaire` bestanden mogen steeds worden geschrapt. Het `binair` zijn van een bestand wordt bepaald door de `binary` sleutel in het corresponderende `brocade.json` bestand.

- Tekst bestanden, die geen objecten definiëren, mogen steeds worden geschrapt. Niet vergeten de linken te schrappen naar de objecten die voorkomen in deze bestanden.

- Object definiërende bestanden (`*.[dil]`) worden geschrapt indien hun objecten niet meer worden gebruikt.

Deze laatste voorwaarde maakt het echt ingewikkeld:

- objecten kunnen worden gebruikt in tekstbestanden
- objecten kunnen worden gebruikt in andere objecten

Deze voorwaarden moeten worden onderzocht. Tevens moet er worden rekening gehouden met de `objectsnotreplaced` sleutel in de `brocade.json` files.


## Conclusie

Uit het voorgaande is het duidelijk dat er heel minutieus moet worden omgesprongen met het schrappen van bestanden. Meestal wordt er ook niet 1 bestand geschrapt maar wel een groep samenhorende bestanden zoals bijvoorbeeld een project.

