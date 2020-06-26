---
title: "Interludium: Het Brocade template systeem"
date: 2020-06-24T11:56:55+02:00
featured_image: "/images/template.svg"
---

Het *Brocade Template System* (BTS) is werkelijk uit zijn voegen gebarsten. Niet alleen worden de mogelijkheden nog geregeld uitgebreid maar ook de toepassingsgebieden nemens steeds toe.

BTS is het ideale niveau tussen programmeren enerzijds en metadatering anderzijds. Gebruikers hebben vrij snel door wat de grote contouren zijn van het templatesysteem. Het zit hem - net zoals bij programmeren - echter in de details, en dat vergt grondige kennis van de diverse mogelijkheden.

Daarom organiseren we een tutorial over BTS en deze tekst dient om deze tutorial wat te begeleiden.


## Basisinstrumenten

Eerst en vooral is er de [documentie](https://dev.anet.be/doc/brocade/system/templates): dit is een wat droge maar uitgebreide omschrijving van de mogelijkheden.

Er werd ook een [speeltuin](https://dev.anet.be/menu/templatepractice) voorzien waarmee templates kunnen worden getest en ideeen uitgeprobeerd.

## Geschiedenis

Voordat *BTS* werd ontwikkeld, werkten we in Brocade met een ander template systeem. Dat systeem heeft veel gemeenschappelijks met BTS maar is complexer, minder rigoureus gedefinieerd en is ook heel wat minder krachtig. Spijtig genoeg is dit systeem nog op diverse plaatsen in gebruik. We belichten later welke technieken er kunnen worden ontplooid om dit probleem aan te pakken.

## De onderdelen van een template

Een template bestaat uit 2 delen:

- een *voorschrift* (ook wel de template genaamd)

- een verzameling van placeholder/waarde paren: de sleutels

Deze onderdelen komen precies met de 2 *partijen* die betrokken zijn bij het werken met templates:

- de persoon die de template samenstelt
- de persoon die de nodige placeholders ter bechikking stelt

De persoon die de templates samenstelt moet weten welke *placeholders* (de eerste component van een sleutel) ter beschikking staan.

## Bedoeling van een template

Teksten, webpagina's, data ... ze bestaan allemaal uit karakters. Sommige onderdelen van deze teksten zijn vaste gegevens, andere zijn dan weer afhankelijk van de context waarin ze worden gebruikt.

Het *voorschrift* van de template gaat zo goed mogelijk de bewuste teksten voorstellen. De dingen in de tekst die veranderen zijn met de context gaan dan worden voorgesteld door een *placeholder*.
Dit *vervangen* van de placeholder door zijn waarde, lijkt eenvoudig maar dit gaat meestal gepaard met een logica en dee logica vatten is het moeilijke in het omgaan met templates.

Dit vervangen van de placeholders en de bijhorende logica noemen we *het evalueren van de template tegenover de sleutels*


BTS is tekstueel: dit betekent dat zowel *template*, *placeholders* en *resultaat* steeds karakterrijen (strings) gaan zijn. 

Het is een goede raad om *templates* te formuleren in [ASCII](https://en.wikipedia.org/wiki/ASCII), toch mogen ze - net zoals waarden en het resultaat - perfect in [UTF-8](https://en.wikipedia.org/wiki/UTF-8) zijn.

Nog even benadrukken dat BTS gericht is op te worden gebruikt in een [M](https://en.wikipedia.org/wiki/MUMPS) omgeving en vanzelfsprekend komt het systeem vooral tot zijn recht in een Brocade omgeving.


## Voorbeelden van templates


Een template zonder sleutels (en zonder context: er is slechts 1 mogelijk resultaat)

```
De hoofdstad van België is Brussel
```

Als we een overzicht van alle landen en hun hoofdstad willen maken, dan moeten we veranderlijkheid inbouwen in onze template.

Merk nog op dat het `$` teken een placeholder inleidt. Er bestaan verschillende soorten placeholders, de meest voorkomende is diegene die met een `$` begint en dan uit kleine letters en cijfers bestaat.

Een neveneffect is dat niet alle letters letterlijk mogen worden genomen: sommige letters - zoals de `$` hebben een speciaal gebruik. BTS draagt er zorg voor dat deze speciale karakters *zeldzaam* zijn in het gewone gebruik.

```
Land: $country
Hoofdstad: $capital
```

Met sleutels:

- country: België
- capital: Brussel

wordt het resultaat:

```
Land: België
Hoofdstad: Brussel
```

Ok, maar wat als je nu een dollar symbool in je tekst wil zetten? Dan moet je `escapen`: dit is laten voorafgaan door een `\`. Meteen ken je een tweede speciaal karakter.

```
Bij McDonald's kost een kop koffie 1\$
```

Na evaluatie:

```
Bij McDonald's kost een kop koffie 1$
```

## Placeholders

### Gewone sleutels

We hebben reeds een eerste type van templates gezien: deze die beginnen met `$` en verder uit letters en cijfers bestaan.

Maar hoe weet je nu waar de placeholder eindigt in de template ? (Beginnen is gemakkelijk: dat is een `$`)

Stel dat je "Kareltje" of "Jantje" wil zeggen, en je placeholder is `$kind` met de waarde `Karel` of `Jan`.

Wordt de template dan `$kindtje` ?

Neen, natuurlijk niet: de template kan onmogelijk vermoeden dat de placeholder `$kindtje` is!

Daarom moet je de *reikwijdte* van de placeholder afschermen  met `{` en `}`. De template wordt:

```
{$kind}tje
```

of zelfs:

```
{$kind}tje
```


`{` en `}` zijn veel gebruikte karakters in `BTS` maar hun deel is steeds hetzelfde: een gebied markeren en afschermen.


### Tekstfragmenten

Een andere vorm van placeholder is die met een `.` en voor de rest cijfers en letters.

De placeholder verwijst dat naar een tekstfragment.

Met:

```
lgcode alphatoomega:
    N: «Α to Ω»
    E: «Α to Ω»
    F: «Α to Ω»

lgcode menu.templateexec:
    N: «Gecontroleerde code voor templates»
    E: «Checked code for templates»
    F: «Code contrôlé pour templates»
```

De template

```
Van $.alphatoomega: $menu.templateexec
```

evalueert in het Nederlands tot:

```
Van Α to Ω: Gecontroleerde code voor templates
```

Meteen leren we dat het evalueren van een template steeds in de context van een taal gebeurt.


### Andere templates

Een placeholder kan ook beginnen met een `@`. De placeholder verwijst dan naar een andere template.


### Omgevingsplaceholders

Als een placeholder begint met een `$` gevolgd door een *HOOFDLETTER* en het is geen van de vorige placeholders, dan wordt deze gezocht in de werkende M omgeving

### Vaste placeholders

Als er gebruik gemaakt wordt van de een placeholder die niet tot de vorige groepen behoort, dan wordt hij gezocht in de collectie van de vaste placeholders.

- technische waarden: maxindex
- context: lg, workstation, staff, job, date, time, session, page, desktop, service, ip
- alle griekse letters: alpha, beta, gamma, ...
- buitenbeentjes: e, smile, unique
- nuttig: true, false, grave, question, empty, quotation, minus, apostrophe, percent, space, crlf, wspace

### Meervoudige placeholders

Sommige placeholders kunnen meer dan 1 waarde hebben. Zo is er de placeholder `$planet`, deze heeft als (opeenvolgende waarden): Mercurius, Venus, Aarde, Mars, Jupiter, Saturnus, Uranus, Neptunus, Pluto.



### De defaultwaarde

Er kan een default waarde voor placeholders zijn. Indien de placeholder nergens wordt gevonden en er *is* een default waarde, dan wordt deze gegeven.

Een defaultwaarde kan worden gespecificeerd in de sleutelverzameling, in de template of in de oproepende code.

Is er geen default waarde, dan crasht de code!



## De pijplijn

Templates vormen een echte pijplijn: op elk moment is er een resultaat en dat resultaat kan worden vervormd to een ander resultaat en dan weer ...

Het speciale karketer dat de volgende fase van de transformatie inluidt, is `|`. Het wordt gevolgd door een *werkwoord* en argumenten. Werkwoord en argumenten zijn gescheiden door een spatie.

De argumenten kunnen placeholders zijn, getallen of strings tussen dubbele aanhalingstekens.

Eens je in de pijplijn zit, weet BTS steeds of je met een placeholder te maken hebt. Bijgevolg hoeven de `$` niet meer.

De werkwoorden heten `modifiers`. Welke modifiers er zijn en hoe ze worden gebruikt moet je uit de documentatie halen. Er zijn er op dit ogenblik reeds [135](https://dev.anet.be/doc/brocade/system/templates#overzicht) gedefinieerd en deze behandelen diverse situaties. Elk op zich zijn het eenvoudige constructies maar samen vormen ze een uiterst krachtig systeem.

Met behulp van `{` en `}` moet je steeds aangeven welk gebied er betrekking heeft op de pijplijn.


### Stringmanipulatie

De template

```
{Dag | after staff | upper}
```

evalueert tot:

```
DAGRPHILIPS
```

### Brocade concepten

De template

```
{Titelbeschrijven | menu "bibrec"}
```

evalueert tot:

```
<a␣href="/menu/bibrec">Titelbeschrijven</a>
```


De template

```
{ | menu "bibrec"}
```

evalueert tot:

```
<a href="/menu/bibrec">Titelbeschrijvingen invoeren/wijzigen</a>
```

De template

```
{Titelbeschrijven | menu "bibrec" "" "c:lvd:3"}
```

evalueert tot:

```
<a␣href="/menu/bibrec/c:lvd:3">Titelbeschrijven</a>
```

### BTS concepten

```
{menu.templateexec | text}
```
evalueert tot:

```

Gecontroleerde␣code␣voor␣templates
```

Stel dat we de sleutel `menuitem: templateexec` hebben,

dan:

```
{menu.$menuitem | text}
```
evalueert tot:

```
Gecontroleerde␣code␣voor␣templates
```

### Booleaans waarden

Elke waarde kan worden gebruikt in een Booleaanse uitdrukking: 

- een lege string is `vals`
- `0` is `vals`
- de rest is `waar`

Dan zijn er de Booleaanse uitdrukkingen:

- `uitspraak` is enkel waar indien `!uitspraak` vals is
- `uitspraak1 && uitspraak2` is enkel waar indien beiden waar zijn
- `uitspraak1 || uitspraak2` is enkel vals indien beiden vals zijn

### Wiskundige constructies

Met `<` en `>` kunnen uit wiskundige constructies Booleaanse waarden worden gemaakt.


### De `?` modifier

Deze modifier moet steeds vooraan staan in de pijplijn en er kunnen 1 of 3 argumenten zijn.

Is het eerste argument `false`, dan wordt het ganse gebied gewist!


```
{Karel en Herman{ en Vincent | ? 1>2}}
```
evalueert tot:

```
Karel␣en␣Herman
```

Met 3 argumenten kan de modifier gebruikt worden in een loop:

```
{{$planet, | after " "} | ? true 1 ##planet}
```

evalueert tot:

```
Mercurius,␣Venus,␣Aarde,␣Mars,␣Jupiter,␣Saturnus,␣Uranus,␣Neptunus,␣Pluto,␣
```

Nog beter:

```
{{{$planet, | after " "} | ? true 1 ##planet-1} | rstrip ", "} en {$planet | ? true ##planet ##planet}
```

evalueert tot:

```
Mercurius,␣Venus,␣Aarde,␣Mars,␣Jupiter,␣Saturnus,␣Uranus,␣Neptunus␣en␣Pluto
```

Eigenlijk kan het eenvoudiger :-)

```
{planet | join ", " 1 -1} en {planet | subscript -1}
```

evalueert tot:

```
Mercurius,␣Venus,␣Aarde,␣Mars,␣Jupiter,␣Saturnus,␣Uranus,␣Neptunus␣en␣Pluto
```


















