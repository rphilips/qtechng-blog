---
title: "Output"
date: 2020-08-08T10:11:15+02:00
featured_image: "/images/output.svg"
---

Najaar 2006.

Microsoft bracht een nieuwe shell uit, [de PowerShell](https://en.wikipedia.org/wiki/PowerShell). Nogal wat Unix/Linux affecionados konden enkel een smalend schouderophalen opbrengen. Ik dacht daar toch anders over: Unix/Linux had een krachtig pipe-systeem waarbij toepassingen informatie konden uitwisselen door de output en input streams te ketenen.

Essentieel was deze informatie overdracht echter beperkt tot tekst.

Niet zo in PowerShell: daar konden heuse objecten worden getransfereerd. Het klinkt allemaal wat abstract, maar ik kan je het verschil het beste uitleggen met `docman`. Docman is een Brocade toepassing die blobs (documenten) beheert.

Deze documenten worden gekarakteriseerd door een identificatie die lijkt op een file path, bijvoorbeeld: `/exchange/66fe04/lc.bin`.

Als je de eigenschappen wil weten van dit document gebruik je de `docman` toepassing (geschreven in *Python*):

```bash
moto /library/tmp> docman -properties /exchange/66fe04/lc.bin
path=/exchange/66fe04/lc.bin
file=/library/database/docman/exchange/x6/6f/e04lc.bin.rm20200421
size=4053
md5=fcf4aff144fd688333a889951f6cc72b
shorturl=/docman/exchange/66fe04/lc.bin
longurl=https://anet.be/docman/exchange/66fe04/lc.bin
```

Het komt geregeld voor dat je deze informatie wil delen met een andere (niet-python) toepassing. Typisch gebeurt dit via piping of via een tussenliggend bestand.

Het hoeft geen betoog dat dit heel foutgevoelig, weinig flexibel en inefficiënt is.

In PowerShell kan je deze informatie vatten als een object en als dusdanig uitwisselen met andere toepassingen.

In `qtech` ben ik verschillende malen op dit probleem gestoten. Ik maakte de toepassing met het oog op menselijke consumptie (zoals trouwens de meeste Unix toepassingen). Al snel liep ik op tegen allerlei hindernissen. De resultaten van de toepassingen moesten kunnen worden getoond in een `wxPython` toepassing. Aha, dergelijke toepassingen kunnen ook HTML aan en een extra parameter was geboren: `HTML=yes`. Vlijtig herwerkte ik de output van (10-tallen) commando's en sub-commando's zodat ook HTML output mogelijk was. Toen kwamen [Emacs](https://en.wikipedia.org/wiki/Emacs), [Textadept](https://en.wikipedia.org/wiki/Textadept), [Sublime Text](https://en.wikipedia.org/wiki/Sublime_Text) en [Visual Studio Code](https://en.wikipedia.org/wiki/Visual_Studio_Code). Telkens kon ik aan de slag: zowel in de `qtech` toepassing zelf als in de bewuste applicaties.

Met `qtechng` wil ik het beter doen. Ik kon wel geen gebruik maken van *echte* objecten: we willen immers `qtechng` gebruiken op diverse platformen en samenwerkend met diverse toepassingen.

*The Next Best Thing* is `JSON`. 

`JSON` - goed geformatteerd - is best leesbaar en uitstekend geschikt om met allerlei technologieën te worden verwerkt. Alle commando's en sub-commando's van `qtechng` gaan dus `JSON` produceren (tenminste indien dit opportuun is voor dit commando). Deze `JSON` heeft ook een heel herkenbare structuur.

Een paar voorbeelden die de kracht van deze aanpak illustreren.

Op mijn werkstation:

```bash
cd /home/rphilips/qtechng/brocade/edit/lab/application
qtechng file add file1.txt file2.txt --version=9.92 --qdir=/lab/application # maak 2 nieuwe bestanden
{
"host": "rphilips-home",
"time": "2020-08-08T11:01:58+02:00",
"RESULT": [
{
"arg": "file1.txt",
"version": "9.92",
"qpath": "/lab/application/file1.txt"
},
{
"arg": "file2.txt",
"version": "9.92",
"qpath": "/lab/application/file2.txt"
}
]
}
```

Het JSON object heeft steeds dezelfde structuur: *host*, *time* en *RESULT* komen altijd terug.

Hm, ga je zeggen, dit is toch wel heel erg *verbose*. Dat is zo. Het is immers de bedoeling dat als deze gegevens dienen te worden verwerkt,  er *NIET* meer aan `qtechng` dient te worden gesleuteld: de gemakkelijk te verwerken JSON output moet voldoende zijn.

Trouwens ...

In een vorige blogpost heb je kunnen kennismaken met `JSONPath`. Deze technologie kan worden gebruikt om de output drastisch te vereenvoudigen. Het goede nieuws is dat er in `qtechng` een `JSONPath` processor is ingebouwd! Deze kan eenvoudig worden geactiveerd door een `jsonpath` flag mee te geven aan het commando.

Voorbeelden:

```bash
cd /home/rphilips/qtechng/brocade/edit/lab/application
qtechng file add file3.txt file4.txt --version=9.92 --qdir=/lab/application --jsonpath="$.RESULT"
[
{
"arg": "file3.txt",
"version": "9.92",
"qpath": "/lab/application/file3.txt"
},
{
"arg": "file4.txt",
"version": "9.92",
"qpath": "/lab/application/file4.txt"
}
]
```

of nog korter:

```bash
cd /home/rphilips/qtechng/brocade/edit/lab/application
qtechng file add file5.txt file6.txt file7.txt --version=9.92 --qdir=/lab/application --jsonpath="$.RESULT[:].qpath"
[
"/lab/application/file5.txt",
"/lab/application/file6.txt",
"/lab/application/file7.txt2"
]
```

Een volgende blog post zal het verwerken van fouten onder de loep nemen.
