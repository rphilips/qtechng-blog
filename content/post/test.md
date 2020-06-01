---
title: "Test"
date: 2020-05-31T16:45:31+02:00
featured_image: "/images/test.svg"
---


Dit is een bijdrage van Bart: interpreteer deze tekst als een overzicht van de problematiek. `testen` is een munt met verschillende kanten. Later worden deze van nabij besproken.

## Inleiding

In deze blog gaan we het hebben over het belang van softwaretesten op verschillende niveaus. Ik denk dat niemand overtuigd moeten worden van het belang maar het is wel belangrijk om de niveaus van softwaretesten te onderscheiden en zo ook communicatie er over te verbeteren.

Deze blog wil dan ook de discussie starten om in de toekomst verder te gaan met software testen binnen Anet met een duidelijk jargon.

## Belang van software testing

Goede softwaretesten kunnen zorgen voor

* klantentevredenheid
* documentatie
* performantie
* clean code

En dat is natuurlijk belangrijk. Laat me deze punten verder uitlichten.


### Klantentevredenheid

Softwaretesten kunnen fouten/defecten van een softwaresysteem in een vroeg stadium identificeren, wat op zijn beurt de kwaliteit/stabiliteit van een product verbetert en vertrouwen in het product opbouwt. Met "vroege fase" bedoel ik, waar het nog steeds haalbaar en effectief is om de bestaande gebreken makkelijk te verwijderen en dus zeker niet na een release.

1 negatieve ervaring met software kan 100 goede ervaringen teniet doen.

### Documentatie

Iets dat vaak over het hoofd gezien is dat softwaretesten ook een goede (aanvullende) documentatie van de code zijn. Een goede softwaretest geeft meteen ook duidelijk aan wat verwacht wordt van een stuk software om te doen. 
Zowel in verwachte als onverwachte situaties.

In ideale omstandigheden zou een bug moeten leiden tot een extra software test of gewoon een extra case voor een bestaande software test.

De meest extreme variant om softwaretesten te gebruiken als documentatie is *Test Driven Development (TDD)*. Hierbij is het idee dat voordat je software schrijft je eerst alle mogelijke test-scenarios schrijft die initieel allemaal moeten falen aangezien code ontbreekt en gaande weg de ontwikkeling wel allemaal zullen slagen.

### Performantie

Softwaretesten kan je keer op keer automatisch laten runnen. En zo kan je ook makkelijk monitoren of het herschrijven van een stuk code de performantie ten goede komt.
Of zien wel stuk code wel heel veel geraakt wordt en een goede kandidaat is om performanter te maken en/of nog beter te testen om het zo kritisch is.


### Clean code

Software testen kunnen op meerdere manieren leiden tot *clean code*. 1 aspect hierbij is het gebruik van *code coverage*. 
Met code coverage kan je zien welke lijnen code geraakt worden door testen. En zo kan je opmerken dat het onmogelijk is bepaalde lijn code te raken. Neem bijvoorbeeld volgende snippet

```python

function not_smart():
    if a:
        ...
        a = None
    ... 
    if a:
        print("...")

```

Als tussen beide if-testen niks gebeurd met `a` zal je de 2de if-test nooit waar zijn. Nu dit voorbeeld is heel duidelijk maar wat als er 100 regels code staan tussen deze 2 if-testen en je net een software aanpassing wil doen/bug oplossen in de buurt van deze 2de if-test. Je kan je te pleuris zoeken achter nut van 2de if-test. Maar als je goede softwaretesten hebt met coverage had je deze 2de if-test al lang verwijderd.



## Soorten testen

Je kan testen op meerdere niveaus indelen en in literatuur vind je hier ook heel wat tegenspraken/spraakverwarring. Hier een aanzet om de testen te omschrijven binnen Brocade om zo tot uniform taalgebruik te komen

Ik zie binnen brocade volgende testen

* operational acceptances testing (OAT)
* unit testen
* systeem testen
* integratie testen
* code testen

En het is niet altijd eenvoudig om een test in één van deze hokjes te delen.
Maar je hebt wel testen nodig op verschillende niveaus. Het internet staat vol met memes en grappige filmpjes waarom er nood is aan verschillende soorten testen. Zoals [Unit versus integration tests door lock](https://www.youtube.com/watch?reload=9&v=0GypdsJulKE) of [Unit versus integration tests umbrella](https://www.youtube.com/watch?v=mC3KO47tuG0)

Laat in volgende secties dieper ingaan op (praktische) verschillen. En het onderstaande is geen wet, maar voer tot discussie!

### OAT

Operational acceptances testing (OAT) is de verzameling van testen om te kijken of alles aanwezig en werkend is om de software te laten draaien.
Ik ben zelf geen specialist in Ansible, maar mijn inziens moet Ansible hier in een groot deel voorzien.
Natuurlijk werkt Brocade niet als bijvoorbeeld `m4_strUpper` niet werkt. Het feit dat deze niet werkt kan veel oorzaken hebben, Mumps, C-library.

Zoals ik het begrijp, is `Check.py` oorspronkelijk bedoeld om OAT-testen te doen. Maar nu bevat deze zowel OAT als unit testen.

Mijn voorstel is `Check.py` geleidelijk aan te verwijderen en te vervangen door `CheckOAT.py` en `CheckUnit.py` met dus respectievelijk OAT en unit testen.

Nu voor we dat kunnen moeten we wel overeenkomen om duidelijk de twee werelden te scheiden.

Mijn inziens is het alvast niet aan OAT-testen om resultaten te controleren. Dus een OAT-test kan zijn `m4_strUpper(RDstr, "ibm")` maar of `RDstr="IBM` valt buiten de scope van OAT-testen. 
Pas als OAT-testen heeft het zin om verdere software testen te doen.

Een ander voorbeeld ik weet dat de slack-tool een specifieke versie van van slackclient nodig heeft, dus mijn inziens is een goede OAT-test

```python
from packaging import version
from slack import WebClient

assert version.parse("2.5.0") <= version.parse(slack.version.__version__)  <= version.parse("2.6.0")
```

Deze gaat crashen als slack ontbreekt als package en fout geven als versie niet in orde is.

Om terug te komen op macro's, we zouden bij bepaalde essentiële macro's een speciaal `example` kunnen zetten die OAT-testen kunnen oppikken met een example dat moet worden. Nogmaals, niet om juistheid macro te testen, maar wel dat macro oproepbaar is. Denk hierbij aan essentiële macro's zoals die waar C-code achterzit om onderscheid met GT.M en Cache.

### Unit testen
Unit testen, zoals de duidelijk in de naam, is het testen van 1 unit, functie, ...
Naar mijn ervaring helpt het schrijven van unit testen ook in het opsplitsen van functies. Het is vaak eenvoudiger en leesbaarder om een hulpfunctie apart te testen dan als deze hulpcode in de hoofdfunctie zit.

Zoals eerder vermeld zou ik deze unit testen onderbrengen in `CheckUnit.py`.
Voor Python is een handige tool voor unit-testen PyTest, als kan PyTest ook dienen voor OAT, Systeem, en Integratie-testen. Meer info over PyTest vind je in [een rst over PyTest](https://dev.anet.be/doc/brocade/system/html/pytest.html)

Belangrijk bij een unit testen is zoveel mogelijk de functionaliteit te isoleren. Stel dat jouw functie een andere functie oproept die heel veel logica doet, dan mock je idealiter deze functie uit. En injecteer dus de mogelijk resultaten van deze functie. Anders ben je eigenlijk met een systeem test bezig. Nu, dit is de theorie en bijvoorbeeld binnen Python is dit haalbaar, maar niet binnen Mumps.

### Systeem/ integratie testen
Van het moment dat je meer dan 1 unit tegelijk test spreekt men strikt genomen over systeem-test. Ik zelf merk de meeste verwarring over de naam "Systeem"-test, want soms wordt deze ook gebruikt voor OAT.

De meerwaarde van een systeem test zit hem vooral als je een groot systeem test. Dus de volledige flow van een call. Bijvoorbeeld het resultaat testen van `https://dev.anet.be/oai/abua/server.phtml?`. 

Het grote verschil met integratie-testen is dat je binnen je systeem blijft. Bijvoorbeeld als je een centaur-import wil testen is dat een systeem test als je het resultaat van de externe service mocked. Als je effectief data binnenhaalt van een externe server of data naar een externe server stuurt, spreken we van integratietesten.

Integratietesten hebben vooral meerwaarde t.o.v. systeemtesten om te kijken of de afgesproken API nog werkt en dat er niet opeens meer data komt dan verwacht of onder ander formaat.

Wat men in praktijk vaak doet, is een vlag zetten of een test tegen live-server spreekt of gebruik zal maken van mock-servers.

De meerwaarde van systeem/integratie testen t.o.v. unit testen komt aan bod onder "Coverage".

Nu binnen brocade denk ik dat we op meerdere levels systeem testen kunnen maken.

* louter mumps
* louter python en mumps data mocken

En als integratie-testen beschouwen de hele flows. Je zou binnen Brocade Mumps als externe service kunnen zien. Het is wel belangrijk dat we effectief import testen, maar bijvoorbeeld het offline zijn van een externe server moet in de "sweep", of binnen welk proces dit ook terecht komt, een andere prioriteit krijgen dan het mislukken van oai-export of falen van leen.

Dit is zeker nog stof tot discussie hoe we deze theorie rond best-practises in praktijk brengen.

Praktisch kunnen voor deze testen zowel klassieke testen (???t*.m, PyTest, ...) gebruikt worden en kan ook Selenium een goede kandidaat zijn.

### Code testen
Naast functionaliteit testen kun je ook testen op kwaliteit van broncode.

Ten eerste kun je een [Linter](https://en.wikipedia.org/wiki/Lint_(software)) gebruiken. We zijn allemaal vertrouwd met de Mumps parser en bewust van de meerwaarde om fouten te voorkomen. Flake8 is een tegenhanger voor Python.

Wat betreft Flake8 moet zeker nog eens de discussie gevoerd worden wat we als standaard nemen. Momenteel worden nog bepaalde errors genegeerd zoals "E722 do not use bare 'except'" en kunnen we strikter gaan door te testen op relatieve imports, *-import, gebruik van enkele versus dubbele quote.

Ik zou daar ver in durven gaan maar belangrijk is vooral dat we hiervoor tot gezamenlijk akkoord komen.

Naast linting zijn er nog mogelijkheden om (test) code kwaliteit te verbeteren die ik hieronder beschrijf.


#### Coverage

Nog een handige tool om code te verbeteren is test-coverage.
Test coverage bepaalt in hoeverre het runnen van de testen, code raakt. Typisch wordt dit uitgedrukt in een percentage. Dus een test-coverage van 80% wil zeggen dat als je alle testen runt, je 80% van de code hebt aangeraakt en dus gebruikt.

Daarnaast kun je ook zien welke code wel en niet wordt aangeraakt. In extremis kun je zelfs zien welke code het meest wordt aangeraakt, maar aangezien de coverage bepaald wordt door het aantal testen moet je dit dan met korrel zout nemen.
Het interessantste is om te gaan kijken welke code niet wordt geraakt want dit kan twee dingen betekenen:

* deze code is niet getest
* je kunt deze code niet testen want onbereikbare code zie `function not_smart()` in het begin van de blog.

Coverage berekenen voor Python kun je makkelijk bekomen m.b.v. PyTest en werkt zelfs al, bijvoorbeeld `scrutiny pytest coverage=yes`. Voor Mumps heeft Bashkar een voorzet gegeven om dit te implementeren en dat maakt onderdeel uit van [BR510-128](https://brocade.atlassian.net/browse/BR510-128)

Nu hoe ver gaan in test coverage? 100% test-coverage kan zeker geen kwaad, maar vergt wel een hele inspanning. Als je op het net zoekt naar blogs enzovoort over coverage is dit vaak punt van discussie.

Ik denk dat wat betreft core-software, 100% test-coverage een must is. En voor de rest moeten we streven naar 100%. Ik denk alvast dat als we eenmaal de tools hebben voor test-coverage we moeten streven elke release in test-coverage te stijgen.

Waarbij we onderscheid moeten maken tussen coverage van unit en systeem/integratie testen. Je kunt met unit-testen normaal makkelijker 100% coverage bekomen. Maar de kans is dat je in een unit-test code kan testen die in de praktijk niet kan aangeraakt worden. Dit komt dan naar boven met systeem testen. Maar dat wil wel zeggen dat je je testen slim moet opdelen tussen systeem en unit-testen.

Een systeem-test zou geen code mogen aanraken die in de praktijk nooit aangeraakt wordt.

Wat dan met bijvoorbeeld macro's die future proof gemaakt worden en momenteel nog niet ten volle functionaliteit gebruikt worden? Ten eerste, maak macro's niet te complex dus test coverage kan je daar bij helpen.
En coverage wijst je dan op feit dat code misschien best herzien wordt.

Nu, binnen brocade zitten we ook met routines die in meta zitten en die geven de grootste blind-spot. Specifiek binnen Mumps als je een routine die niet met `%`  begint, niet kan coveren met een systeem test is dit een goede kandidaat om van dichterbij te bekijken.
Maar met `%` is het complexer. Dus ik denk dat we ook hier nog werk is om een overzicht te bekomen van routines in meta. Misschien dat we i.p.v. UTF8-scanner voor globals een routine scanner moeten maken.


#### Mutatietesten

Een iets meer omstreden techniek die toch zijn meerwaarde bewezen heeft is *mutatietesten*. Hierbij stel je eigenlijk je softwaretesten op de proef. Het idee is dat een software tool op doordachte wijze kopieën maakt van de originele code en daar wijzigingen aan doet om vervolgens de software testen opnieuw te runnen. Als software testen dan slagen, is er een probleem ...

Voorbeeld:

```Mumps
fn %dubbel(PDa):
. n a,b
. s a=2
. s a=PDa*2
. q a

sub %TstDubbel:
. w:0'=$$%vb(0) !,"FAIL!"
. w:4'=$$%vb(2) !,"FAIL!"
. q
```

`%TstDubbel` zorgt ervoor dat `%dubbel` 100% test coverage heeft. Wat dus wil zeggen elke lijn code van `%dubbel` wordt aangeraakt als de test loopt.
Het is op het zicht duidelijk (omdat het zo een klein voorbeeld is) dat de lijn `s a=2` onnuttig is. Iets wat een mutatietest bijvoorbeeld gaat doen is `s a=2` vervangen door `s a=3`. Als dan testen nog slagen is er iets mis.
In dit geval onnodige code.

Maar mutatietesten gaan ook typisch operaties wijzigen en dus `s a=PDa*2` vervangen door `s a=PDa**2` en in dit geval gaan testen nog altijd slagen. Dus in dit geval mist er een test-case zoals `w:10'=$$%dubbel(5) !,"FAIL!"`
