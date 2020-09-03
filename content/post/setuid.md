---
title: "Setuid"
date: 2020-09-03T15:37:19+02:00
featured_image: "/images/setuid.svg"
---

## Het probleem

[Setuid](https://en.wikipedia.org/wiki/Setuid) is een *privilege elevation mechanism* dat gangbaar is in de Unix/Linux wereld. 

Als ik me niet vergis ontsproot het aan het creatieve brein van [Dennis Ritchie](https://en.wikipedia.org/wiki/Dennis_Ritchie), de ontwerper van de C programmeertaal.

Het systeem houdt zeker beveiligingsrisico's in maar het is uiterst handig ... als het goed wordt aangewend.

In klassieke Linux/Unix (we laten even ACL's buiten beschouwing) worden de mogelijkheden om om te gaan met de resources van een computer bepaald door wie je bent. 
Soms is dat echter niet voldoende: stel je hebt een spreadsheet. Een gebruiker mag die spreadsheet wel degelijk manipuleren maar ... dan wel met het juiste instrument: bijvoorbeeld wel met *LibreOffice* maar niet met *Emacs*.
Je kan dan zorgen dat de gebruiker geen schrijfrechten heeft op het document.
Door het `suid` of `guid` bit te zetten op *LibreOffice* kan je er voor zorgen dat onze gebruiker - zolang hij LibreOffice - gebruikt de identiteit aanneemt van de eigenaar van de LibreOffice executable.

Met andere woorden, voor kritische toepassingen, zorgvuldig de eigenaar en groep kiezen en dan de suid/guid plaatsen, is een oplossing.

Maar hier zit een addertje onder het gras. Vele (Brocade) toepassingen zijn scripts. Scripts zijn executables die beginnen met de [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) operator `#!interpreter [optional-arg]`.

Voorbeeld:

```python
#!/library/bin/py2 -O

import sys
import os

from anet.toolcat import toolcat
import anet.docman.docman

if __name__ == "__main__":
    toolcat.execToolcatCommandStack(sys.argv[1:], toolcatApplication="docman")
```

In de Linux wereld heeft men begrepen dat het zetten van een `suid` hier serieuze veiligheidsrisico’s inhouden. Je kan daar meer over lezen op [stackexchange](https://unix.stackexchange.com/questions/364/allow-setuid-on-shell-scripts).
Linux doet dan alsof `suid/guid` niet is gezet op scripts! (En ze zijn hierbij heus niet alleen in de Unix wereld)




Allemaal goed en wel, maar in Brocade en in de installatieprocedures van `QtechNG` hebben we nu eenmaal nood aan `setuid`. Ook in scripts!

## Oplossing

Er zijn 2 soorten van executables die dienen te worden geïnstalleerd: de executables die van *buitenaf* komen en de eigengemaakte software. De eerste groep wordt geplaatst door Ansible ☂️. 

Het is de tweede groep, de zelfgemaakte software, die tot de verantwoordelijkheid van `QtechNG` behoort.

Ik heb nu een *proof of concept* uitgewerkt die kan dienen voor elke script in Brocade. Hoe dan ook, de software wordt steeds geïnstalleerd via functies uit `/core/python3/installer.py`.

Een goed voorbeeld zijn toolcat applicaties. Zo wordt de toolcat applicatie `mutil3` geïnstalleerd door:

```python
from anet.core import installer

installer.toolcat('mutil3', suid=True)
```

Na installatie staat de executable `mutil3` in de directory `/library/bin` (bepaald door de registry waarde `bindir`).

Onderhuids gebeurt het volgende:

Is `suid=False`, dan wordt een [hard link](https://en.wikipedia.org/wiki/Hard_link) gelegd met het programma `toolcatgo3`, eveneens in `/library/bin`.

Is `suid=True`, dan wordt een [hard link](https://en.wikipedia.org/wiki/Hard_link) gelegd met het programma `toolcatgo3s`, eveneens in `/library/bin`.

Nu is `toolcatgo3s` een hard link naar `toolcatgo3` ! Het `suid` bit is echter gezet op `toolcatgo3s` en niet op `toolcatgo3`.

Duizel je even van alle hard links: alle toolcat applicaties linken naar ofwel `toolcatgo3` of naar `toolcatgo3s` en die 2 linken nog eens naar elkaar. Met andere worden vele inode entries in de directory maar slechts 1 bestand.

Maar, zal je zeggen, als dit allemaal hetzelfde bestand is ... hoe weet de software wat dan uit te voeren?
Wel, het onderscheidend vermogen is de naam. In ons voorbeeld is dat `mutil3` en dat is voldoende om de Python script perfect op te starten.

De basis is een simpele go software `/anetsu/system/toolcatgo3.go` waar de kritische dingen met plezier worden uitbesteed aan de robuuste en veilige go library.

Met Alain is afgesproken dat we dit in release `5.10` enkel uittesten met `mutil3` (een toepassing die enkel door ontwikkelaars wordt gebruikt). Als alles zonder problemen verloopt, wordt dit in release `5.20` doorgevoerd naar alle kritische toepassingen.



