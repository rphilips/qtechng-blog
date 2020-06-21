---
title: "Parallel"
date: 2020-06-21T10:58:25+02:00
featured_image: "/images/parallel.svg"
---

Een doelstelling van `QtechNG` is dat overkoepelende acties zoals de `bootstrap` en de `sweep` sneller verlopen.

Met *sneller* bedoel ik niet een 10% winst maar heb ik het eerder over 2 tot 3x zo snel.

Cruciale momenten in het leven met Brocade zijn de oplevering van nieuwe releases en het installeren van een nieuwe ontwikkelversies.

Beiden nemen nu uren in beslag. Niet alleen zou het een stuk comfortabeler zijn indien dit *sneller* zou kunnen, maar het zou bovendien de mogelijkheid scheppen om het aantal uitgebrachte releases drastisch op te voeren.
Voeg je daarbij ook de systeem configuratie, via Ansible, ook opgenomen wordt in `QtechNG`, dan is het duidelijk dat elk beetje extra helpt bij het bereiken van de doelstelling.

De voornaamste troef om deze snelheid te bereiken is parallellisme bij het uitvoeren van de diverse taken.

... en laat nu dat zijn waarin `Go` excelleert!

Ik wil echter van meet af aan stellen dat *het onderste uit de kan halen* niet erg verstandig zou zijn!

Het werken in parallel, diverse taken die op hetzelfde moment worden uitgevoerd, kunnen subtiele problemen opleveren die zelden naar boven komen in testscenario's maar die op het moment dat je het net niet kunt hebben, opduiken.

Trouwens, het heeft geen zin een paar seconden af te schaven als de totale tijd van de operatie toch een uur of langer neemt!

Bovendien zijn er heel wat situaties waarin je parallellisme best mijdt: lees er eens ["Async Python is not faster"](http://calpaterson.com/async-python-is-not-faster.html) op na!

Daarom hanteerde ik als aanpak voor parallellisme, de volgende vuistregels:

- Ik gebruik enkel parallellisme bij intensieve I/O operaties
- Ik gebruik enkel het [1 producer / multiple consumer](https://en.wikipedia.org/wiki/Producer%E2%80%93consumer_problem) patroon via een software die ikzelf heb geschreven en door en door begrijp
- Ik structureer mijn software als [pipelines](https://en.wikipedia.org/wiki/Pipeline_(software))

In een vorige blog had ik het over de verschillende stappen die nodig zijn om een bestand op te slaan in `QtechNG`. Om bijvoorbeeld 1 Mumps file weg te schrijven zijn er gemakkelijk acties nodig op 20 verschillende bestanden! (Hierin is dan nog niet de installatie van de M file in de Mumps omgeving zelf opgenomen). Je zou nu kunnen denken: Ok! Een goed moment om deze 20 acties *gelijktijdig* te laten gebeuren. Wel, dat gebeurt dus niet! Het is gewoon veel te moeilijk voor mij om te doorgronden wat ik moet doen als er 1 van deze 20 stappen misloopt. Voeg daar nog bij dat diverse van die stappen afhankelijk van elkaar zijn: m.a.w. het succesvol aflopen van de ene actie is afhankelijk van het succesvol aflopen van een andere actie.
En dan zijn er nog tal van andere problemen die zich aandienen. Maar daarover later meer ...

## Pipelines

Met *pipelines* wordt software opgedeeld in een aantal delen die één voor één (na elkaar) worden uitgevoerd: m.a.w. het tegenovergestelde van parallellisme! Binnen elk deel kan je echter voluit gaan. Het grote voordeel is dat je na elk deel *weet* wat de status is van je toepassing: het is een moment waarop de chaos voorbij is (en hoogst waarschijnlijk een nieuwe chaos begint).

Ik geef een voorbeeld van een pipeline in `QtechNG`. 

Stel, we gaan een nieuw project opladen in het repository. Dit project bestaat uit 20 M-files. Een hoogst efficiënte manier van werken zou kunnen zijn: het project aanmaken in het repository en 20 simultane taken starten: 1 per M-file. Gaan we ervan uit dat elke taak bestaat uit het bewerken van 10 andere bestanden en het installeren van de M-file in de Mumps omgeving, nog eens 2 files raakt. In `Go` is het een koud kunstje om die `20 * (10 + 2) = 240` *goroutines* op te starten die dit voor hun rekening moeten nemen. Dit is werken *ZONDER* pipelining: uiterst snel en ... onbeheersbaar! Denk maar eens na wat er zou gebeuren indien er, behalve die 20 M-files, ook nog een `d-file` met macro's in het project zou bestaan. (Tussen (), hoeveel projecten ken je zonder d-files ?) Ik geef je op een briefje, dat bij diverse M-files, de macro's niet zouden zijn omgevormd!

Met *pipelining* pakken we het wat bescheidener aan: we splitsen de werkzaamheden in 2 delen. 

In het eerste deel stoppen we de 10 M-files en de eventuele d-files in het repository. Deze werkzaamheden zijn onafhankelijk van elkaar: we besteden 1 `goroutine` per file. Is dit deel afgelopen, dan weten we dat de bestanden perfect in het `QtechNG` repository staan. Het tweede deel kan beginnen.

In het tweede deel installeren we de M-routines en of we dit in parallel afwerken moet ik nog uitvissen!

## Producer / Consumer

De valkuilen van het *producer/consumer* design patroon zijn heel goed gekend en ik voel me bekwaam genoeg om hier een go functie voor te maken die aan de eisen van `QtechNG` tegemoet komt: in de package `brocade.be/base/parallel` staat de functie `NMap`

```go

func NMap(n int, parmax int, fn func(m int) (r interface{}, err error)) (resultlist []interface{}, errorlist []error) {
...
}
```

Deze functie werkt uitstekend in de context van een `closure`: voor elke getal beginnend van 0 tot en met `n`-1 moet een functie `fn` worden uitgevoerd. `NMap` verzamelt de resultaten en de fouten van `fn`.

De bedoeling is om deze opdrachten in parallel uit te voeren. We houden het aantal taken die tegelijkertijd lopen, strikt onder controle:

- `parmax`: is dit getal positief, dan mogen er nooit meer *goroutines* worden gelanceerd
- de registry waarde `qtechng-max-parallel`: is deze waarde niet leeg en `parmax` negatief, dan worden er nooit meer *goroutines* opgestart
- is deze waarde toch leeg en `parmax` is negatief, dan worden er nooit meer `goroutines` opgestart dan het aantal cores op de machine (min 1).

Waarom de wens om het aantal goroutines te beperken? Dit is iets dat je met scha en schande leert: ik kwam vlug tot de ontdekking dat er plots problemen opduiken die je niet zo snel ziet aankomen. Bijvoorbeeld dat het aantal files die tegelijkertijd open zijn, beperkt is. Deze beperkingen kunnen per proces en overkoepelend voor het ganse werkend Operating System zijn!

`NMap` werkt volgens het *producer/consumer* patroon. Er worden een beperkt aantal *consumers* (werkers) opgestart, die elk een aantal getallen afwerken. De *producer* zorgt ervoro dat er voldoende werk uitstaat.

## Toch nog opletten!

Zelfs met deze voorzichtige aanpak kunnen er nog problemen rijzen: in package `brocade.be/qtechng/source` definieer ik 2 functies die cruciaal zijn voor `QtechNG`:

- `StoreList`: deze gaat een lijst met source bestanden in parallel *onderbrengen* in het repository
- `UnlinkList`: deze gaat een lijst met source bestanden in parallel *schrappen* uit het repository

Ondanks mijn voorzichtige aanpak maakte ik een kapitale blunder: ik hield geen rekening met de speciale aard van de `brocade.json` bestanden. Bij de opslag moeten deze *eerst* worden gedaan: ze kunnen immers verhinderen dat andere bestanden mogen worden opgeslagen (denk maar aan de uniciteitsregel). Bij het schrappen moeten ze helemaal op het einde worden verwijderd. Gebeurt dit allemaal in parallel, dan weet je ooit welke file er eerst wordt behandeld.

Zelfs het splitsen van deze taak is dat nog niet voldoende: je moet er rekening mee houden dat projecten sub-projecten kunnen hebben. Dit betekent nog dat de `brocade.json`'s bij de opslag moeten worden gesorteerd en bij het schappen zelfs in omgekeerde volgorde.

(Zucht)

## Eerste resultaten
Is het dit allemaal wel waard ?

Wel, de volgende test overtuigde me:
De volgende cijfers geven geen sluitend beeld en ze zijn bekomen op mijn notebook (XPS 13 van 2017, 8 GB RAM, 4 cores, Linux Mint 19.3). 

- 1000 projecten
- elk 100 bestanden
- elk bestand 32K
- elk bestand telde een 10-tal objecten
- maximaal 16 parallelle acties (qtechng-max-parallel)

Het opbouwen (`StoreList`) en afbreken (`UnlinkList`) van het repository nam minder dan 15 minuten in beslag.

Wel bemoedigend!

