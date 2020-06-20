---
title: "Interludium: PEG parsers"
date: 2020-06-19T18:55:55+02:00
featured_image: "/images/peg.svg"
---

[PEG](https://en.wikipedia.org/wiki/Parsing_expression_grammar) (Parser Expression Grammar) parsers gaan in `QtechNG` een belangrijke rol spelen. Als parser systeem is dit een vrij recente ontwikkeling: het basis [artikel](https://bford.info/pub/lang/peg/) van Bryan Ford verscheen in 2004: toen waren de hoogdagen van parsers al lang voorbij. Ik herinner me nog de jaren '80 toen het fameuze boek [Compilers: Principles, Techniques, and Tools](https://en.wikipedia.org/wiki/Compilers:_Principles,_Techniques,_and_Tool) van Aho en Ullman (en anderen) de de facto bijbel was.

PEG parsers kwamen onder mijn aandacht toen ik veel werkte met [Lua](http://www.lua.org/): PEG technologie zat immers standaard ingebakken in de programmeertaal en bewezen daar hoe krachtig dit wel was.

Onlangs bracht Guido Van Rossem deze parsers in de belangstelling met zijn [blogreeks op Medium](https://medium.com/@gvanrossum_83706/peg-parsing-series-de5d41b2ed60) over zijn experimenten met Python. In [PEP 617](https://www.python.org/dev/peps/pep-0617/) geeft hij zelfs een aanzet om Python zelf te formuleren aan de hand van een PEG.

De reden waarom hij dit doet is precies dezelfde reden als waarom ik PEG wil gebruiken in `QtechNG`: je kan op rigoureuze wijze complexe dingen definiëren.
Wist je dat er tot nu toe nog altijd geen ondubbelzinnige specificatie bestaat voor Python ? Het antwoord van het ontwikkelteam was steeds hetzelfde: *De implementatie is de specificatie*.

Onmogelijke vol te houden natuurlijk: er bestaan op dit ogenblik minstens 4 implementaties van Python, allemaal lichtjes verschillend. Hierbij zijn nog niet eens de verschillende versies van Python gerekend!

Programmeertalen maar ook andere, complexe, structuren hebben nood aan een *grammatica* die de structuur op ondubbelzinnige wijze beschrijven. Denk maar aan onze macro’s en lgcodes!

In de informaticawereld heeft men daartoe een structuur van productieregels ontwikkeld. Meestal worden deze productieregels zelf geformuleerd in [Backus-Naur notatie](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form).

Dit is een systeem waarmee men *geldige zinnen* kan maken (produceren) in de grammatica. Het *parsen* van een tekst is dan het onderzoeken of deze tekst een geldige producties is in deze grammatica. Als het even kan worden dan diverse onderdelen uit de zin herkend en daar worden dan weer *acties* mee verbonden. 

Dit is precies hetzelfde als met omgangstaal: tekst is een geldige zin, we kunnen dan onderwerp, werkwoord, meewerkend voorwerp e.d. herkennen en zo begrijpen wat de zin doet.

Je kan wel denken dat het voor een parser wel heel erg complex kan zijn om een zin als *geldig* te kunnen herkennen: soms zet een gedeelte van de zin de parser op het verkeerde been en moet de parser op den duur 'backtracken' om toch de ware structuur te herkennen. Soms is dat zelfs niet mogelijk. In mijn opleiding Informatica, zovele jaren geleden, studeerde ik [Algol 68](https://en.wikipedia.org/wiki/ALGOL_68), een uiterst krachtige en complexe programmeertaal. Het gerucht deed de ronde dat er geen enkele *niet-ambigue* parser voor bestond. Dat gerucht werd in ieder geval versterkt doordat de Siemens mainframe van UGent, geen enkel compilatie tot een goed einde bracht. Studenten hielden wedstrijd om de mainframe zo snel mogelijk te doen crashen met geldige Algol 68.

PEG parsers pretenderen niet dat ze ALLE grammatica's aankunnen. Ze kunnen er echter heel wat aan. Bryan Ford creëerde trouwens een nieuwe techniek - de zogenaamd Packrat parsers - die PEG kunnen laten parsen in een tijd evenredig met de lengte van de aangeboden tekst! Dit ging dan wel ten koste van het gebruikte geheugen. Ach, hoe dikwijls heb ik dit nu al gezien in informatica: de balans tussen tijd, cpu en geheugen!

PEG parsers zijn niet ambigue: met andere woorden elke geldige tekst kan maar op 1 manier geldig zijn. Anders gezegd: de specificatie is ondubbelzinnig. Dat heeft ook nadelen: PEG parsers kunnen dan ook geen grammatica's aan die van nature uit ambigue zijn. Zoals het Nederlands bijvoorbeeld. Hoe zou je een PEG parser kunnen vervaardigen die in alle omstandigheden om kan met een zin zoals *"Het baasje zocht de hond met de verrekijker"*?
Je kan stellen dat PEG parsers heel erg geschikt zijn om om te gaan met *computertext* en heel wat minder met *natuurlijke taal*.

PEG parsers zijn ook [context-vrij](https://en.wikipedia.org/wiki/Context-free_grammar): in de parser wereld is dit *a big deal*. Het betekent dat de resultaten van 1 productieregel mogen worden gebruikt op *elke* plaats waar die productieregel staat en het resultaat zal nog steeds een geldige zin zijn.

Een PEG parser bereikt dit context-vrij zijn en het niet-ambigue karakter door op een specifieke wijze om te gaan met de keuzes in een productieregel. Een productieregel is samengesteld uit andere, eenvoudiger productieregels: net zoals teksten samengesteld zijn uit paragrafen die samengesteld zijn uit zinnen die samengesteld zijn uit woorden. De PEG parser gaat die keuzes 1 voor 1 af en zodra hij een keuze vindt die overeenkomt, zegt hij: "dat is hem" en keert niet meer op zijn stappen terug.

Dit betekent nog dat als je een specificatie voor een bepaalde structuur uitwerkt, je wat moet opletten op de volgorde waarop je dingen test.

Ik geef een voorbeeld. In [XML](https://en.wikipedia.org/wiki/XML) heb je markers voor het begin en einde van een element: vb, `<HTML>` en `</HTML>`.

Als nu je productieregel van de gedaante is:

```
marker ← ( "<" | "</") name ">"

name ← [a-zA-Z]+
```
Dan zal de PEG parser wel de zin `<HTML>` vinden maar nooit de zin `</HTML>`: hij ziet immers de "<" , die matcht en kijkt niet meer verder!

Een goede productieregel is:

```
marker ← ( "</" | "<") name ">"

name ← [a-zA-Z]+
```

Met deze specificatie zijn zowel `<HTML>` als `</HTML>` geldig!

Elke zichzelf respecterende programmeertaal heeft wel een library om PEG-parsers te vervaardigen voor tal van problemen.

Zo ook `Go` (de taal waarin `QtechNG` wordt geschreven). Er zijn er zelfs meerdere.

Mijn voorkeur gaat uit naar [Pigeon](https://github.com/mna/pigeon), PEG ... heb je hem ... 

Niet alleen is Pigeon een kwalitatief hoogstaande parser generator, maar je hebt de library zelfs niet nodig in `QtechNG` !

Hoe zit dat nu?, zal je zeggen. Wel, stel dat je een PEG grammatica maakt voor pakweg een `l-file`, dan kan je Pigeon een go-software laten genereren die compleet op zichzelf staat. Je mag nadien Pigeon gewoon weggooien: je kan rustig verder met de gegenereerde code. Straf!

In latere posts gaan we dieper in op het gebruik van Pigeon bij specifieke grammatica's.

Alain en ik zijn ook aan het uitzoeken of we een generator kunnen bouwen in [M](https://en.wikipedia.org/wiki/MUMPS). Ik zie dit als de perfecte tegenhanger van het Brocade template systeem: in het template systeem stel je een zin samen op basis van diverse onderdelen terwijl je met een PEG parser een zin opsplitst in zijn structuren en daarmee dingen doet.
