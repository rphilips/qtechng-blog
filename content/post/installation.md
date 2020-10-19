---
title: "Installation"
date: 2020-10-08T13:54:21+02:00
featured_image: "/images/installation.svg"
---

In deze blog bijdrage wil beschrijven wat er gebeurt bij een installatie.

Elke installatie begint met een verzameling van *sources*.

Deze *sources* zijn qpaths naar bestanden in het repository: bij een complete installatie van een release zijn dit simpelweg **alle** bestanden uit het repository. In het vervolg verwijzen we naar deze verzameling als de `sourceset`.
Het moet steeds expliciet worden meegegeven aan het installatieproces of we te maken hebben met een *complete* of *partiële* installatie. (In de source code van het `QtechNG` gaat dit via een Booleaanse waarde met de naam `Fcomplete`.)
Bij het installatieproces moet ook expliciet worden meegegeven of de documentatie moet worden aangemaakt. (In de source code van het `QtechNG` gaat dit via een Booleaanse waarde met de naam `Fwithdoc`.)

Nog even aanstippen dat elke source thuishoort in een project met een passende configuratiefile.
In het vervolg gaan we een aantal zaken illustreren met behulp van een bestaand `QtechNG` commando:

```bash

# PYSCRIPT: qpath naar een Python script
# VERSION: QtechNG version

qtechng source py $PYSCRIPT --version=$VERSION
```

Om helemaal goed te begrijpen wat er dan precies gebeurt, ga ik vlug even demonstreren wat `qtechng source py` doet!

```shell

# PYSCRIPT bevat het qpath van de gegeven python script
# VERSION: QtechNG version die van toepassing is

# Maak een tijdelijke directory aan
export WORKDIR=`qtechng tempdir get --prefix=qtechng.`


# Het complete project wordt uit het repository van de huidige productieserver
# gehaald en geschreven in $WORKDIR
# Het uitvoeren van een python script kan immers destructief werken
# Op zijn minst worden er bestanden geplaatst die niet thuis horen in het
# repository (vb. *.pyc bestanden)
cd "$WORKDIR"
qtechng source co $PYSCRIPT --neighbours --version=$VERSION –-tree


# Bereken de absolute filenaam
export ABSPATH=`qtechng file tell --tell=abspath --pattern=$PYSCRIPT --version=$VERSION --recurse`


# Bereken de passende python versie
# Een Python script kan immers met py2 of met py3 werken:
# De versie van Python wordt bepaald door
# - de configuratiefile `brocade.json`
# - het voorkomen van py2 of py3 op de eerste lijn in de script
export PYTHON=`qtechng file tell $ABSPATH --tell=python`

# Bereken het *project* van de script
export PROJECT=`qtechng file tell $ABSPATH --tell=project`


# Let op dat versie en project worden meegeven als parameter:
# Het is aan de script om daar iets mee te doen.
# VERSION__ -> VERSION
# PROJECT__ -> PROJECT
# QPATH__ -> PYSCRIPT

cd "$WORKDIR"
$PYTHON -c "VERSION__='$VERSION'; PROJECT__='$PROJECT'; QPATH__='$PYSCRIPT'; exec(open('$ABSPATH').read())"
```


## sourceset / autoset / installset

De `sourceset` is de naam voor de verzameling van de te installeren bestanden: 

- bij een installatie van een nieuwe release is dit gewoon *ALLE* bestanden
- bij een checkin is dit de verzameling van alle veranderde bestanden.

Bestanden met patroon `*.[bdilmx]` worden *automatisch geinstalleerd*: er is geen extra informatie nodig om deze aan het werk te zetten. 

Nu kan het wel zijn dat sommige van deze bestanden geen *echte* Brocade bestanden zijn: dit wordt bepaald door de `notbrocade` sleutel in de corresponderende configuratie files.

Op deze wijze wordt de `sourceset` opgesplitst in:

- `autoset`: automatisch te installeren bestanden
- `installset`: bestanden die worden geïnstalleerd door een `install.py` bestand in dezelfde directory als de configuratie file.

Source bestanden komen in projecten met hogere of lagere prioriteit. Hoe hoger de prioriteit, hoe eerder ze worden geïnstalleerd.

- eerst komen de projecten waarvan de de sleutel `core` uit de configuratie file op `true` staat, dan de andere
- binnen deze twee groepen komen eerst de projecten met de hoogste prioriteit
- hou er mee rekening dat deze prioriteit *relatief* is: de kinderen van een project komen - ongeacht hun prioriteit - steeds na de ouder.
- als projecten dezelfde prioriteit hebben dan worden ze alfabetisch gesorteerd: op deze wijze is de sortering *stabiel* (lees: *deterministisch*)
- source bestanden worden verder nog gesorteerd op basis van hun relatief path t.o.v het project

In het vervolg gaan we er van uit dat dat de `sourceset / autoset / installset` verzamelingen steeds gesorteerd zijn.

## Installatie van de bestanden

In het vervolg gelden de volgende afspraken:

- OLDVERSION: de environment variable die de oude versie bevat (kan ook leeg zijn)
- VERSION: de environment variable die de te installeren versie bevat.
- de commando's werken onder root

### Stap 1: Synchroniseren van de software van $VERSION

Deze stap synchroniseert de software in `VERSION`.

Merk op: 

- Deze software wordt *niet* geïnstalleerd: registry waarde `brocade-release` verschilt immers!
- Deze stap kan steeds worden uitgevoerd (ook uren vooraleer de andere stappen worden opgestart)

```bash

qtechng version sync $VERSION

```

### Stap 2: Synchroniseren van de software van $OLDVERSION

Deze stap synchroniseert de software in `OLDVERSION`.

```bash

if [ "$OLDVERSION" != "" ]
then
    qtechng version sync $OLDVERSION
fi

```

### Stap 3: Uitvoeren van data aanpassingen binnen de bestaande release

Deze stap komt weinig voor: de bedoeling is om hiermee data aan te passen met software die geldig is in `OLDVERSION`.

Een goed voorbeeld hiervan was de omschakeling naar `UTF-8`.

```bash

if [ "$OLDVERSION" != "" ]
then
    qtechng source py /release/current/nextrelease.py --version=$OLDVERSION
fi

```

### Stap 4: Zetten van `brocade-release`

Merk op dat deze *niet* wordt gezet via de `delphi` toepassing: deze software is misschien nog niet geïnstalleerd!

```bash

    qtechng registry set brocade-release "$VERSION"

```

### Stap 5: Ansible software voor $VERSION

Installatie van systeem parameters en software: dit moet altijd worden uitgevoerd

Het is aan te raden om belangrijke aanpassingen (zoals nieuwe databanksoftware) goed te plannen.

Merk op dat - als je deze stappen zorgvuldig volgt - de `brocade-release` registry waarde correct staat!

### Stap 6: Uitvoeren van *release.py*

Uit de *installset* worden alle `release.py` files genomen (gesorteerd!) en uitgevoerd.

Stel dat we alle qpaths verzamelen in de `bash` array `RELEASEPYs`:

```bash

for releasepy in "${RELEASEPYs[@]}"
do
    qtechng source py $releasepy
done

```

### Stap 7: Installatie van de M-routines

Uit de *autoset* worden alle bestanden met extensie `.m` genomen en geïnstalleerd.
Dit kan parallel gebeuren: volgorde is onbelangrijk,

Stel dat we alle qpaths verzamelen in de `bash` array `ROUTINEs`:

```bash

for routine in "${ROUTINEs[@]}"
do
    qtechng source auto $routine &
done

```

### Stap 8: Installatie van de L-files

Uit de *autoset* worden alle bestanden met extensie `.l` genomen en geïnstalleerd.
Dit kan parallel gebeuren: volgorde is onbelangrijk.

Dit kan misschien niet intuïtief lijken: sommige `lgcodes` zijn immers afhankelijk van andere `lgcodes`.
Echter, het enige wat er gebeurd met de L-files is dat er wordt uitgemaakt *welke* lgcodes er moeten worden geïnstalleerd: de code vist dan de objecten zelf op en verwerkt de data. Dit kan wel degelijk in parallel gebeuren.

Stel dat we alle qpaths verzamelen in de `bash` array `LFILEs`:

```bash

for lfile in "${LFILEs[@]}"
do
    qtechng source auto $lfile &
done

```

### Stap 9: Installatie van de X-files

Uit de *autoset* worden alle bestanden met extensie `.x` genomen en geïnstalleerd.
Dit kan parallel gebeuren: volgorde is onbelangrijk

Stel dat we alle qpaths verzamelen in de `bash` array `XFILEs`:

```bash

for xfile in "${XFILEs[@]}"
do
    qtechng source auto $xfile &
done

```

### Stap 10: Installatie van de B-files

Uit de *autoset* worden alle bestanden met extensie `.b` genomen en geïnstalleerd.
Dit kan parallel gebeuren: volgorde is onbelangrijk

Stel dat we alle qpaths verzamelen in de `bash` array `BFILEs`:

```bash

for bfile in "${BFILEs[@]}"
do
    qtechng source auto $bfile &
done

```

### Stap 11: Initialisering van de meta informatie

Deze stap bevat 2 elementen:

```bash

# installatie van de 'nieuwe' meta in parallel
qtechng version meta

# oudere meta
upython

```

### Stap 12: Uitvoeren van *install.py*

Uit de *installset* worden alle `install.py` files genomen (gesorteerd!) en uitgevoerd.

Stel dat we alle qpaths verzamelen in de `bash` array `INSTALLPYs`:

```bash

for installpy in "${INSTALLPYs[@]}"
do
    qtechng source py $installpy
done

```

### Stap 13: Uitvoeren van de werkplannen

```bash

qtechng source py /release/current/workplan.py

```
