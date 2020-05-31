---
title: "SSH"
date: 2020-05-26T08:09:15+02:00
featured_image: "/images/ssh.svg"
---

Waarom gebruik je [SSH](https://en.wikipedia.org/wiki/Secure_Shell "SSH") in `qtechng`?

Wel, toen we in 1997 begonnen aan de bouw van Brocade, was dit niet zo!

We hadden daarvoor 2 redenen: een goede en een slechte.

Laten we beginnen met de slechte reden. Zoals steeds, als ik gegrepen ben door een idee, dan heb ik de neiging om dat idee tot in het extreme te volgen. In 1997, 1998 was ik er van overtuigd dat web technologie de wereld van informatiebeheerders ging bepalen. Ik wou daarom alle onze instrumenten web gebaseerd maken. Ik zag duidelijk de voordelen: geen gesukkel meer met firewalls, het vergaren van diepe kennis omtrent web technologie en ja, ook het marketing aspect daarvan (Brocade: het Web en niet sdan het Web).

Ik experimenteerde met shells in de webbrowser (en geprogrammeerd in Java!). Voor beveiligde communicatie was er dan [TLS en zijn voorganger SSL](https://en.wikipedia.org/wiki/Transport_Layer_Security "TLS en SSL"). En dat allemaal in [Netscape Communicator 4.71](https://en.wikipedia.org/wiki/Netscape_Communicator "Netscape Communicator").

Het is echter een veeg teken als je meer met de instrumenten bezig bent dan met datgene wat die instrumenten moeten bouwen. Gelukkig was er Wim Holemans die me wees op `SSH`. Dat viel samen met het moment waarop een kwalitatief hoogstaande cliënt voor Windows beschikbaar kwam: [PuTTY](https://en.wikipedia.org/wiki/PuTTY "PuTTY").

In de jaren daarna heb ik steeds gezocht naar een SSH library voor Python. Deze bestaat wel degelijk. [Conch](https://en.wikipedia.org/wiki/Conch_(SSH) "Conch") is een onderdeel van [Twisted](https://en.wikipedia.org/wiki/Twisted_(software) "Twisted") en dat is precies één van de problemen. Twisted is een omvangrijke platform dat bovendien niet echt aansloot bij de standaard manier van ontwikkelen voor Python. Conch was té moeilijk te integreren.

Met `Go` is de situatie helemaal anders: de SSH library wordt onderhouden door het Go-team (hoewel het nog geen echt onderdeel is van de standaard packages: er zijn nog geregeld kleine aanpassingen aan de functionaliteit). Dat is begrijpelijk: SSH is cruciaal van belang voor [Docker](https://en.wikipedia.org/wiki/Docker_(software) "Docker") en [Kubernetes](https://en.wikipedia.org/wiki/Kubernetes "Kubernetes").

In `qtech` wordt de taak van SSH uitbesteed aan CLI's zoals `pscp.exe`. `plink.exe`, `ssh`, `scp`. Per `qtech` invocatie worden er telkens 2 externe executables opgestart wat de performantie zeker niet ten goede komt. De verschillen tussen [OpenSSH](https://en.wikipedia.org/wiki/OpenSSH "OpenSSH") en `PuTTY` veroorzaken heel wat configuratieproblemen en communicatie tussen de verschillende onderdelen gebeurt dan over het filesysteem met als gevolg bestanden die moeten worden opgeruimd en meer van dat fraais.

In `qtech` (en ook in `qtechng` zijn er essentieel 3 communicatievormen die plaatsvinden over `SSH`:

- Een opdracht, geformuleerd op de cliënt (werkstation of productiemachine), wordt ingepakt in een Python pickle, getransfereerd naar de ontwikkelmachine. Daar wordt het antwoord ook ingepakt en teruggestuurd naar de cliënt. Een typische voorbeeld is een zoekactie naar files: ```qtech -list edit '*.m' find='m4_getCatIsbdTitles'```. Deze kan typisch worden uitgevoerd door een `SSH` instructie.

- Deze opdracht heeft betrekking op bestanden op de lokale computer. Deze moeten samen met de opdracht verstuurd worden naar de ontwikkelmachine en daar worden verwerkt. Dit kan heel wat moeilijker worden ingebed in een `SSH` instructie. In `qtech` worden de bestanden ingepakt in een ZIP-bestand en getransfereerd. Daarna wordt de opdracht verstuurd, het ZIP-bestand wordt uitgepakt en de opdracht wordt uitgevoerd. Een typsich voorbeeld is de checkin van bestanden: ```qtech -ci *.*```

- Een opdracht heeft betrekking op bestanden reeds aanwezig op de ontwikkelmachine en vraagt om deze bestanden naar de lokale machine over te hevelen. Een goed voorbeeld is: ```qtech -sync```.

In `qtech` en `qtechng` is er sprake van 2 machines: 1 daarvan is steeds de ontwikkelmachine `dev.anet.be`, de andere is ofwel een workstation, ofwel een productiemachine.

Het is belangrijk om zich te realiseren dat de ontwikkelmachine, `dev.anet.be`, ook moet fungeren als werkstation én productiemachine. Als we de bovenstaande `qtech` operaties uitvoeren, dan mag het communicatie gedeelte geen overhead genereren. Ideaal voor het ontwikkelen van `qtechng` zou zijn dat gans dit proces wordt weggemoffeld.

De `Go` library `golang.org/x/crypto/ssh`, samen met Cobra, maakt dit mogelijk.

Een ander aspect aan het communicatiegebeuren is natuurlijk de serializering van de diverse concpeten: bestanden, opdrachten.

Er zijn 2 wegen die we kunnen opgaan:

- Gestandaardiseerde serializering: de data wordt ingepakt in bijvoorbeeld [JSON](https://en.wikipedia.org/wiki/JSON "JSON") of [Protocol Buffers](https://en.wikipedia.org/wiki/Protocol_Buffers "Protocol Buffers").
- Een specifieke oplossing wordt uitgewerkt.

Ik heb eerst de eerste benadering uitgewerkt. De overhead voor binaire bestanden maakte `JSON` geen goede kandidaat. `JSON` wordt in `qtechng` wel degelijk veelvuldig gebruikt maar dan als datastructuur voor opslag op schijf.
Hoewel `Protocol Buffers` een excellente oplossing is, heb ik het toch niet weerhouden: immers in het communicatieproces zijn de beiden einden in dezelfde taal (`Go`). Hadden we 2 verschillende technologien gehad dan waren `Protocol Buffers` de juiste weg.

Uiteindelijk heb ik geopteerd voor `encoding/gob`, het elegante en performante serializeringsprotocol ingebouwd in `Go`.

Ik geef nu een voorbeeld van hoe gebruik te maken van `Cobra` en `SSH in Go`:

```go
package cmd

import (
    "encoding/hex"
    "os"

    qresult "brocade.be/qtechng/result"
    "github.com/spf13/cobra"
)

var aboutCmd = &cobra.Command{
    Use: "about",
    Short: "Useful information about `Qq`",
    Long: `Version and builttime information about Qq`,
    Args: cobra.ArbitraryArgs,
    Example: "Qq about",
    RunE: about,
    PreRun: func(cmd *cobra.Command, args []string) { preSSH(cmd) },
    Annotations: map[string]string{
       "remote-allowed": "yes",
    },
}

func init() {
    rootCmd.AddCommand(aboutCmd)
}

func about(cmd *cobra.Command, args []string) error {
    msg := map[string]string{"!BuildTime": BuildTime, "!BuildHost": BuildHost, "!BuildWith": GoVersion}
    host, e := os.Hostname()
    if e == nil {
        msg["!!uname"] = host
    }
    if len(args) != 0 {
    for _, arg := range args {
        msg["hexified "+arg] = hex.EncodeToString([]byte(arg))
    }
    }
    Fmsg = qresult.ShowResult(qresult.RMAnswer(msg))
    return nil
}
```

Je kan de code op 2 manieren activeren: (`Qq` is de voorlopige naam voor `qtechng`)

```bash
Qq about
```

en:

```bash
Qq about --remote
```

In het eerste geval vertelt de software je iets over de versie van `Qq` op je werkstation:

```bash
(base) ~/tmp$ Qq about
{
    "host": "rphilips-home",
    "time": "2020-05-26T10:05:48+02:00",
    "RESULT": {
        "!!uname": "rphilips-home",
        "!BuildHost": "rphilips-home",
        "!BuildTime": "2020.05.24-11:30:43",
        "!BuildWith": "go1.14.3"
    }
}
(base) ~/tmp$
```

In het tweede geval krijg je informatie over de ontwikkelmachine:

```bash
(base) ~/tmp$ Qq about --remote
{
    "host": "rphilips-VirtualBox",
    "time": "2020-05-26T10:07:13+02:00",
    "RESULT": {
        "!!uname": "rphilips-VirtualBox",
        "!BuildHost": "rphilips-home",
        "!BuildTime": "2020.05.15-15:36:53",
        "!BuildWith": "go1.14.2"
    }
}
(base) ~/tmp$
```

Bij de ontwikkeling van `func about` is het communicatiegedeelte (over SSH) onzichtbaar: je ontwikkelt voor het gemakkelijkste geval waarbij er gewoonweg geen communicatie is!
