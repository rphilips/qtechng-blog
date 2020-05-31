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

Laat in volgende secties dieper ingaan op (praktische) verschillen

### OAT

(later hierover meer)

* Check.py
* Ansible

### Unit testen

(later hierover meer)

* pytest
* NIET in check.py

### Systeem testen

(later hierover meer)

* moeilijkste binnen mumps
* meerdere units tegelijk testen tegen mock data

### Integratie testen

(later hierover meer)

* "live" testen
* selenium

### Code testen

(later hierover meer)

* Linting
* Mumps parser
* coverage


#### Coverage

(later hierover meer)


* hoever in gaan

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



