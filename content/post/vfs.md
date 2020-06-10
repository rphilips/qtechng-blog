---
title: "Virtuele filesystemen"
date: 2020-06-10T17:55:19+02:00
featured_image: "/images/vfs.svg"
---

Met deze blogbijdrage wil ik een lans breken voor een techniek die niet alleen een groot gebruikersgemak oplevert voor de ontwikkelaar maar ook een paar (dramatische) fouten kan voorkomen!

We gaan het hebben over [Virtuele Filesystemen](https://en.wikipedia.org/wiki/Virtual_file_system "Virtual file system").

Een `VFS` vertrekt steeds van een reeds bestaand filesysteem: dat kan zijn het goed gekende filesysteem zoals het op je notebook staat, maar dat kan ook een Dropbox folder zijn, een simpele ZIP-file, of iets dat op AWS staat of op Google Drive.

Wij, Brocade mensen, kennen maar al te goed WebDAV: door middel van een instrument zoals Webdrive wordt een webserver aangeboden net alsof het een lokale schijf is.

Kenmerkend is dat er een soort bemiddelbaar bestaat die het `VFS` op een meer vertrouwde manier aanbiedt.

Deze bemiddelaar kan echter ook een bibliotheek zijn die door de ontwikkelaar kan worden aangewend om bestanden te lezen, te schrijven, te wissen, te doorzoeken, ...

Een goed voorbeeld van een `VFS` uit de `Python` wereld, is [PyFilesystem](https://www.pyfilesystem.org/).

Ook in `Go` zijn er talrijke `VFS` te vinden en dat hoeft je niet te verwonderen: de designers van deze programmeertaal hebben het I/O systeem - cruciaal voor filesystemen - op een waarlijk voortreffelijke manier uitgebouwd. `VFS`-en in `Go` kunnen op een zeer natuurlijke manier worden uitgebouwd.

Zo'n `VFS` heeft diverse voordelen: met een minimum aan inspanningen kan de code operationeel worden gemaakt op [Amazon Web Services](https://en.wikipedia.org/wiki/Amazon_Web_Services "AWS") of simpelweg in RAM. Dit laatste is bijvoorbeeld zeer handig als je de `QtechNG` software wil testen: voor je repository switch je van harde schijf naar RAM en, na afloop van je testen, is alles mooi opgeruimd!

In `QtechNG` gebruik ik diverse `VFS`.

Laat ik eerst de problemen (of: gevaren) schetsen die ik tegenkom met de *gewone* filesystemen.

Het is duidelijk dat het `QtechNG` repository tot diepe folderstructuren leidt. Dit zal trouwens nog erger worden als we ook de opslag van objecten (samen met hun gebruik in bestanden) gaan behandelen. 

Dit heeft tot gevolg dat de aanmaak en afbouw van folders en subfolders heel zorgvuldig moet gebeuren. Ik wou daarom dat de klassieke `mkdir` in `QtechNG` dezelfde functionaliteit kreeg als `mkdir -p`: alle, nog niet gedefinieerde, tussenliggende folders worden automatisch aangemaakt.

Echter, vergeet niet dat het repository als een databank moest fungeren: ik wou dus ook dat, als folders leeg zijn, deze ook automatisch worden opgeruimd!

Kijk, met klassieke file operaties is dat om moeilijkheden vragen:

- je vergeet al eens een folder te schrappen (als hij verder geen bestanden bevat)
- maar nog veel erger, het is echt niet uit de lucht gegrepen dat het schrappen te ver gaat en folders worden opgeruimd waar dat beter niet zou bij gebeuren.

De oplossing ligt in het organiseren van een `VFS`. Zoals dat in Brocade context meestal het geval is, stopt het niet bij het in gebruik nemen van een software. Neen, er wordt een heuse fabriek opgezet om dergelijke `VFS` te genereren.

De basis ligt in [Afero](https://github.com/spf13/afero "Afero"), een software van de makers van *Cobra*.

Hier heb ik een aantal methodes aangepast:

- Bij het schrappen van een bestand wordt er gekeken of er nog bestanden in de parentfolder staan en is dat niet zo, *en het gaat hier niet om de rootfolder*, dan wordt de folder zelf meedogenloos geschrapt
- Alle schrijfacties zijn atomair
- Bestanden behoren steeds tot de groep `db` en ze kunnen enkel gelezen en beschreven worden door leden van die groep
- Aanmaak van een directory maakt ook de tussenliggende directories aan
- Filesystemen kunnen `readonly` zijn (zeer nuttig bij zoekacties)
- De separator is steeds `/`

Er worden (op dynamische wijze) filesystemen aangemaakt voor de verschillende Brocade versies, voor elk project, voor de objectbomen, enz. De `root` van elk dergelijk filesysteem is zodanig dat je daar niet kunt buiten opereren.

Het mag duidelijk zijn dat ik echt opgetogen ben over deze werkwijze, een werkwijze die we trouwens nog op heel wat andere plaatsen kunnen aanwenden in Brocade.


