---
title: "Source"
date: 2020-06-09T16:25:22+02:00
featured_image: "/images/source.svg"
---

Een bestand wegschrijven in het `QtechNG` repository ?

Dat kan toch niet zo moeilijk zijn!

Neen, het is inderdaad niet zo moeilijk maar je moet wel heel erg minutieus te werk gaan!

Ik wil beklemtonen dat deze bijdrage enkel gaat over gewone bestanden: met andere woorden het gaat niet over *object definiërende* bestanden
(dat zijn de bestanden van de gedaante `*.[ild]`): we gaan die afzonderlijk bespreken.

Ook het installeren in de productieomgeving wordt niet behandeld: dus we gaan niet uitleggen hoe een bestand van de gedaante `*.m` in `M` terechtkomt.

Er zijn diverse aspecten die we willen bespreken.

## Waar precies wordt een bestand weggeschreven ?

Dit hangt af van verschillende parameters:

- in de eerste plaats de registry waarde in de sleutel `qtechng-repository-dir`
- vervolgens de release (deze moet steeds - impliciet of expliciet - worden opgegeven)
- het `qtechng-path` van de source file: dit is een systeem onafhankelijke voorstelling

Om het met `python` termen te zeggen:

```python

release = "5.20"
repository = registry("qtechng-repository-dir")
qtechngpath = "/take/application/takwone.m"

filename = os.path.join(repository, release, "source", "data", *qtechngpath.split("/")[1:])
```

Wat die "data" component daar komt bij doen, houden we voor later!

## Bepalen van het project waartoe een bestand behoort

Eens dat de filenaam is bepaald, kunnen we gaan zoeken naar het project waartoe de file behoord.

Te beginnen vanaf `os.path.join(repository, release, "source", "data")`, schuimen we alle directories af, op zoek naar naar de `brocade.json` files.

De laatste `brocade.json` file die we vinden, zegt ons meteen wat het `project` is waartoe ons bestand behoord. 

Je vraagt je wellicht af waarom het niet beter is van *omgekeerd* te werk te gaan: eerst in dezelfde directory kijken waar onze bestand staat en dan afdalen, richting `os.path.join(repository, release, "source", "data")`. Dat lijkt zeker efficiënter.

Het is echter zo dat brocade configuratie files (`brocade.json` bestanden) met behulp van de sleutel `notconfig`, sommige `brocade.json` bestanden kunnen merken als *niet-configuratie bestand*!

Het kunnen bepalen tot welk project een bestand behoort is echt wel belangrijk: een bestand zonder project wordt simpelweg niet opgeslagen in het repository!

## Wat met `brocade.json` ?

Bestanden met een basename gelijk aan `brocade.json`, moeten speciaal worden behandeld. Als `QtechNG` uitvist dat het om een waarachtige configuratiefile gaat, dan wordt zorgvuldig gecontroleerd of die voldoet aan het JSON schema en of er geen overtollige - en mogelijke schadelijke - data in staat. Pas als aan alle testen voldaan zijn, kan het bestand worden geplaatst.

De reden voor deze voorzichtigheid is eenvoudig: eens een foutieve configuratiefile in het systeem terecht komt, kan die niet meer met de `QtechNG` software worden verwijderd en moet deze manueel worden aangepast.

## Unieke bestanden

Sommige bestanden moeten een unieke basename hebben!

Denk maar aan de M routines (en hun schermfiles `*.x`). De precieze structuur van die unieke bestanden wordt gespecificeerd door `registry("qtechng-unique-ext")`.

Om de uniciteit van deze bestanden te bewaken, maakt `QtechNG` in `os.path.join(repository, release, "unique")` een structuur aan voor *alle* bestanden. (De registry waarde kan immers veranderen en dan moeten we *klaar* staan voor die verandering).

In `unique` wordt er voor ons bestand een path gedefinieerd als volgt:

```python
basename = os.path.basename(filename)
bdigest = SHA512(basename)
fdigest = SHA512(filename)

uniquename = os.path.join(repository, release, "unique", bdigest[:2], bdigest[2:], fdigest)

# in uniquename wordt `{"path": qtechng-path van bestand} weggeschreven
```

Op deze wijze kan snel worden uitgevist, of er al een bestand bestaat met dezelfde basename.

Nog even meegeven dat de constructie van uniqename schaamteloos geleend is uit andere technologieën: zowel `git` als `hg` gebruiken gelijkaardige constructies. Zo is de splitsing van `bdigest` ingegeven om de directories niet over te bevolken!

Bestanden die zondigen tegen de uniciteits-regel worden niet weggeschreven in het repository: ook deze fouten kunnen immers niet altijd door `QtechNG` worden rechtgezet.

Het uniciteitsverhaal is hiermee nog niet ten einde: in de configuratie kan immers met de sleutel `notunique` uitzonderingen op de regel worden gemaakt. Dit is belangrijk om bijvoorbeeld M routines toe te laten die verschillen op `GT.M` en `Cache`. Een uitzondering kan gewettigd zijn als we er maar voor zorgen dat ze niet beiden worden geinstalleerd.

## Meta informatie

Per source file wordt een beperkte set aan meta data bijgehouden. Deze komt terecht in `os.path.join(repository, release, "unique")`. Deze meta informatie is een JSON structuur die tijdstippen van aanmaak en laatste update bijhouden, samen met de userid van de verantwoordelijken.

De plaats waar deze meta informatie terecht komt, is in grote mate gelijk aan de constructie van de unieke namen:

```python
fdigest = SHA512(filename)

metaname = os.path.join(repository, release, "meta", fdigest[:2], digest[2:]+".json")
```

## Test op token

Als het bestand wordt aangeboden om te worden weggeschreven, moet dit vergezeld zijn van een `token`. Dit token moet bewijzen dat je begonnen bent met dit bestand te downloaden uit het repository en dat je daar dan veranderingen hebt aan aangebracht.

Dit `token` reist steeds mee met dit bestand. Dit `token` (een SHA512 digest) wordt gecontroleerd tegenover het reeds aanwezige bestand. Klopt het `token` niet, dan wordt de opslag geweigerd en moet de gebruiker het bestand opnieuw downloaden (samen met het juiste token), zijn aanpassingen aanbrengen en terug aanbieden.

Overigens, samen met de verkeerde `brocade.json` en de uniciteits regel, zijn dit de enige situaties waarbij aangeboden bestanden *niet* worden weggeschreven in het repository.

## Atomair wegschrijven van de bestanden

Het definitief wegschrijven van de bestanden is een belangrijk zaak: Alain zou zeggen: "Dit moet in steen worden gebeiteld".

Alle voorzorgen moeten worden genomen opdat het wegschrijven compleet gebeurd: het niet wegschrijven van een bestand is erg, maar het corrupt of partieel wegschrijven is nog veel erger.

Gelukkig bestaan er systeem onafhankelijke, atomaire operaties die dit mogelijk maken: eerst wordt het bestand opgeslagen onder een andere naam in dezelfde directory en tenslotte wordt er een `rename` uitgevoerd (onder windows moet er eerst wel een delete van het originele bestand gebeuren).

## Eind goed, al goed ...

Dat dacht je maar.

In volgende blog posts gaan we het nog hebben over *virtuele filesystemen* en *parallelle* acties.