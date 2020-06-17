---
title: "Tekst versus binair"
date: 2020-06-17T19:21:17+02:00
featured_image: "/images/textbinary.svg"
---

## Wat is een tekstbestand ?

Een eenvoudige definitie is: een tekstbestand bestaat uitsluitend uit ([Unicode](https://home.unicode.org/)) karakters. Het vervelende hierbij is dat je, behalve het tekstbestand en zijn inhoud, ook de encoding moet opgeven: als je `CP-1252` gebruikt, is elk bestand tekst.

Om het onderscheid te maken in `qtech`, volgde ik een pragmatische benadering. 

Ik werkte in 3 stappen:

- Had het bestand een filenaam een extensie en behoorde die extensie tot een bepaalde verzameling (vb. `{".js", ".m", ".d", ".html", ".zwr"})` dan concludeerde ik: dit is een `tekstbestand`.

- Had het bestand een filenaam een extensie en behoorde die extensie tot een andere verzameling (vb. `{".pdf", ".zip", ".png", ".xls", ".odt"})` dan verklaarde ik het bestand `binair`

- Had het bestand geen extensie, of lag de extensie buiten deze beide verzamelingen, of ... werd de data aangeleverd zonder filenaam, dan volgde ik een algoritme dat ik in de code van de [Perl](https://www.perl.org/) programmeertaal vond. (`Perl` had een operator - `-T` als ik het goed heb - waarmee je kan testen of een bepaald bestand binair was). Dit algoritme nam de eerste 4K bytes en deed daar allerlei analyses op en besloot daaruit met `tekst` of `binair`.

## Waarom is dat belangrijk ?

Dit is belangrijk omdat toepassingen nu eenmaal anders omgaan met tekstbestanden en binaire bestanden: open je een binair bestand met je - van Emacs verschillende - editor, dan is de kans groot dat je editor crasht.

Gebruik je [grep](https://en.wikipedia.org/wiki/Grep) om bestanden te doorzoeken naar tekst, dan gaat `grep` enkel de tekstbestanden beschouwen. Daar kan je je aardig aan verbranden zoals ik onlangs tot mijn scha en schande heb ervaren: ik doorzocht een `*.zwr` file (`tekst`, weet je wel) naar afbeeldingen die in Docman stonden. Als ik de afbeeldingen *niet* vond in het bestand, dan mocht ik ze schrappen uit Docman. Wel, `grep` concludeerde dat de betreffende `*.zwr` file, `binair` was! Er stond immers bitmapindexen in, die het algoritme deden misleiden. Gevolg: `grep` vond niets. Gevolg: ik schrapte teveel afbeeldingen... (gelukkig met backup :-)

In `qtech` werd het onderscheid tussen tekstbestanden en binaire bestanden voor 2 redenen gemaakt:

- Bij zoekopdrachten: enkel tekst werd doorzocht
- Bij substitutie van `m4/i4/r4/l4` constructies: ook deze vonden enkel bij tekstbestanden plaats.

## Hoe wordt het onderscheid in `QtechNG` gemaakt ?

`QtechNG` stapt af van deze willekeurige behandeling en verklaart: **alle bestanden zijn tekst totdat het tegendeel wordt geconfigureerd**

In de configuratie file `brocade.json` kan je, per project, perfect opsommen - eventueel met wildcards - wat de binaire bestanden zijn: daartoe bestaat de sleutel `binary`.

Aanverwant aan deze sleutel is er nog de sleutel `objectsnotreplaces`. Hiermee kan, per project en per object, worden aangegeven in welke *tekstbestanden* er geen substitutie mag plaatsvinden: handig bij documentatie bijvoorbeeld.
