---
title: "Registry"
featured_image: "/images/registry.svg"
date: 2020-05-22T13:18:57+02:00
---

Brocade is verregaand geparametriseerd: meta-informatie bepaalt de specifieke functionaliteit en het uitzicht. Het minitieus parametriseren van een complex systeem kan enkel in een getrapt systeem en met verschillende technologieeen.

- Sommige meta-informatie wordt handmatig verzameld en zijn intrinsiek verbonden met de doelstellingen van een bibliotheeksysteem: catalografische beschrijvingen, gebruikersbeschrijvingen

- Om deze meta-informatie adequaat te beschrijven heb je instrumenten nodig. Er mee rekening houdend dat niet alle Brocade installaties volgens dezelfde procedures en richtlijnen werken, is er weer meta-informatie nodig om deze instrumenten scherp te stellen naar een specifieke situatie toe.

- Software en data moeten tenslotte worden geexploiteerd in services: software, data en services moeten concreet worden georganiseerd op servers. Om deze passend - denk: performantie, afscherming, systeemonafhankelijkheid - in te bedden op een actieve machine, moeten er keuzes worden gemaakt die te maken hebben met filesystemen, hardware, netwerking. Deze keuzes moeten op hun beurt worden vastgelegd in meta-informatie. Deze keuzes noemen we in Brocade de *registry*. De *registry* is een gestructureerd bestand ergens op de server.

- Diverse systeem componenten moeten de *registry* kunnen terugvinden. Daarom wordt de plaats waar de *registry* zich bevindt vastgelegd in een `environment variabele` die ter beschikking is van elk proces op de server (`BROCADE_REGISTRY`).

Bij het opzetten van deze environment variabele moet je ermee rekening houden dat een Operating System op verschillende manieren deze variabele kan zichtbaar maken:

- in *M* sessies
- in *web* sessies
- in *SSH* sessies
- in *SHELL* sessies

Deze doorgedreven visie op meta-informatie - *een bibliotheeksysteem is het beschrijven van meta-informatie met een paar aanvullende services* - biedt zo zijn voordelen:

- een eenvoudige richtlijn om bibliotheek software te construeren: laat de software passen in dit getrapt model

- terugvindbaarheid van de diverse componenten door het getrapte systeem af te dalen of op te klimmen

- afstelbaarheid van het bibliotheeksysteem naar lokale noden

- onafhankelijkheid van de hardware

- onafhankelijkheid van het operating system

## Structuur van de registry

De registry is opgeslagen in een file op het filesysteem van de server. De structuur is een eenvoudige key/value store, verwoord in een JSON object. De `key` is wat in de Brocade software wordt gebruikt en welke in runtime of bij installatie door de onderliggende software wordt omgezet in de `value`.

De plaats waar de registry wordt bewaard komt uit een environment variabele `BROCADE_REGISTRY`. De systemadministrator stelt deze environment variabele (en de bijhorende locatie) ter beschikking van elk Brocade process (interactieve shells, Web interface, SSH).

Beste praktijk (op een `UN*X` systeem):

```bash
   export BASE=/library/database

   export BROCADE_REGISTRY=$BASE/registry/registry.json
   touch $BROCADE_REGISTRY

   chmod --reference=$BASE $BASE/registry
   chown --reference=$BASE $BASE/registry/registry.json
   chmod u=rw,g=r,o= $BASE/registry/registry.json

   touch $BASE/registry/localregistry.json
   chown --reference=$BASE/registry/registry.json $BASE/registry/localregistry.json
   chmod --reference=$BASE/registry/registry.json $BASE/registry/localregistry.json

   touch $BASE/registry/saltregistry.json
   chown --reference=$BASE/registry/registry.json $BASE/registry/saltregistry.json
   chmod --reference=$BASE/registry/registry.json $BASE/registry/saltregistry.json
```

Er zijn verschillende manieren hoe en sleutel/waarde paar kan worden toegevoegd aan de `registry`:

- Door middel van de *ansible installatie*: de systemadministrator weet immers het beste waar bepaalde bestanden thuis horen.
- Manueel via de `delphi` applicatie
- Als onderdeel van `qtechng` via de `release.py` scripts in de projecten

Voor redenen van performantie en gebruikersgemak wordt deze `JSON` structuur ook omgezet naar een `M` structuur. Deze omzetting gaat automatisch.

De sleutels zijn strings en worden samengesteld volgens de reguliere uitdrukking :regexp:`[a-z][a-z0-9-]*[a-z0-9]`. In de sleutel wordt het koppelteken |MINUS|

Er zijn een aantal (niet-bindende) afspraken:

- de eerste component duidt het grote gebied aan waarvoor de sleutel wordt gebruikt: vb. `process-base-dir`

- een directory eindigt op `-dir`

- een executable eindigt op `-exe`

- een URL eindigt op `-url`

- bestandsnaam eindigt op `-file`

- registry sleutels die een *wachtwoord* bevatten, *moeten* eindigen op `-password`!

- de Brocade software moet zowel met `http` als met `https` kunnen worden gebruikt, afhankelijk van de keuze van de gebruiker. Gebruik daarom voor URLs steeds een [absolute-path reference](https://www.ietf.org/rfc/rfc3986.txt "URLS")

- sommige waarden zijn commando's uit te voeren in de shell:
  - beperk dit zoveel mogelijk
  - laat `PATH` zijn werk doen
  - gebruik *nooit* wildcards
  - zorg ervoor dat deze commando's geconstrueerd zijn volgens de richtlijnen van de *Bourne shell* (POSIX)

## Schema

zijn `registry.json` bestanden die voldoen aan het [registry schema](https://dev.anet.be/brocade/schema/registry.schema.json "Registry")

## Samenstellen van de registry

Sleutels in de registry zijn *niet* evenwaardig:

- sommige sleutels zijn *berekenbaar* en worden enkel opgenomen omdat het berekenen ervan te omslachtig is of te veel tijd zou nemen. Een voorbeeld hiervan is `os-sep` (separator van directories en bestandsnamen)

- sommigen zijn afhankelijk van andere sleutels: vb. `xml-catalog-dir` is afhankelijk van `web-base-dir`.

Een ontwikkelaar die een nieuwe registry waarde nodig heeft, volgt de volgende stappen:

- Is de nieuwe registry waarde afhankelijk van een reeds bestaande registry waarde, definieer dan in de projectfile `release.py` de nieuwe registry waarde

- Is de nieuwe registry waarde in te stellen door de system administrator, definieer dan de registry waarde in `/core/brocade/release.py`. De ontwikkelaar kan 2 strategieën volgen:

  - is er een goede default waarde, neem dan deze

  - kies anders een waarde die de installatie van het project doet falen

  De ontwikkelaar documenteert deze registry waarde in het project `/doc/registry`.

## Gebruik van de registry

De registry wordt het best interactief bevraagd via het `delphi` commando.

Er zijn een paar details die belangrijk zijn om weten:

- bij de bevraging van de registry mag `-` in de sleutel ook worden vervangen door een `_`
- eindigt de sleutel op een `-` en begint de waarde met een `/`, dan wordt de inhoud van `registry(web-base-url)` geplaatst vóór de waarde in de sleutel (zonder eindigende `-`)
- het opvragen van een sleutel die eindigt op een `:` geeft de documentatie van deze sleutel *zonder* deze |:|
- in `M` gebruik je het beste de `m4_getDelphiValue` macro.
- in `python2` is er de constructie `from anet.core.registry import registry; value = registry(key, 'default')`
- in `python3` is er de constructie `from anet.core.base; value = base.registry(key, 'default')`

In tekstbestanden kan steeds de constructie `r4_key` worden gebruikt. *key* is een registry sleutel met `_` notatie.
Het installatieproces gaat dan deze constructie vervangen door de waarde in de registry.

Deze techniek is soms de enige om aan parametrisering te doen. Toch is deze niet aan te raden: in situaties (|M|, |Py2|, |Py3|) waar zonder performantie verlies andere oplossingen bestaan, zijn deze te verkiezen.

## Documentatie van de registry

De registry waarden worden gedocumenteerd in project `/doc/registry`.

Is `xyz` een registry sleutel, maak dan een bestand `xyz.rst` aan en noteer in dit bestand wat de registry waarde betekent.

Hanteer daarbij de volgende afspraken:

- gebruik `/doc/registry/os-sep.rst` als voorbeeld
- documentatie in `reST`
- in de documentatie heeft de effectieve waarde geen zin (het systeem gaat dat zelf wel tonen)
- vermeld zeker de intentie van de registry sleutel en bijzonderheden (restricties) op de waarde.

De *documentatie* van de registry waarden die niet langer worden gebruikt in de software, moeten handmatig worden geschrapt in het project `/doc/registry`.

Maak het onderscheid tussen registry waarden die niet gedefinieerd zijn maar die *toch* worden gebruikt in de software. De documentatie van deze registry waarden moet vanzelfsprekend blijven bestaan.

## QtechNG

Er worden diverse registry waarden aangemaakt die bedoelt zijn om `QtechNg` goed te laten lopen. Deze sleutels hebben allen de prefix `qtechng-`.
