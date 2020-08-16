---
title: "Lgcode"
date: 2020-08-16T12:11:55+02:00
featured_image: "/images/lgcode.svg"
---

Bij de constructie van Brocade software, worden teksten steeds ingegeven onder de vorm van *tekstfragmenten*.

Tekstfragmenten kunnen zowel in de software als in de Brocade toepassing worden gedefinieerd. Sommige van deze tekstfragmenten kunnen voor lokaal gebruik ook worden aangepast.

In de Brocade software worden tekstfragmenten aangemaakt in `*.l` bestanden: dit zijn speciaal gestructureerde bestanden die allen de extensie `.l` hebben.

Merk op!

Door middel van de `notbrocade` eigenschap uit `brocade.json` kan men `*.l` bestanden aanstippen die *geen* tekstfragmenten definiëren.

QtechNG onderzoekt deze `L-files` op hun syntax, extraheert en verwerkt de tekstfragmenten en stelt deze op diverse wijzen ter beschikking van de Brocade software.

Er bestaan zeker krachtiger systemen om tekst te beheren: in Unix middens is vooral [GetText](https://en.wikipedia.org/wiki/Gettext) goed gekend. `L-files` hebben echter het voordeel dat ze toegankelijker zijn voor niet-ontwikkelaars en dat ze ook in de vorm van spreadsheets naar vertaalbureaus kunnen worden gestuurd.

## Tekstfragmenten

Een tekstfragment is een Brocade object dat op unieke wijze wordt gekenmerkt door middel van een identifier. Deze identifier noemen we ook wel een `lgcode` (`lg` staat voor *language*).

Met zo'n `lgcode` worden diverse attributen geassocieerd: samen bepalen ze het gedrag en de mogelijkheden van het tekstfragment.

## De `lgcode`

Tekstfragmenten worden gegroepeerd in `namespaces`. Deze `namespace` kan je ook terugvinden in de vorm van de `lgcode`: het is het stuk van de identifier tot het eerste punt. Staat er geen punt in het tekstfragment of begint het tekstfragment met een punt, dan is de namespace `brocade`.

De volgende vormen worden geaccepteerd als `lgcode` (vorm wordt gegeven als een reguliere uitdrukking):

- `^[0-9a-zA-Z_ -]+$`

Dit zijn de klassieke `lgcodes` (namespace `brocade`)

Voorbeeld: `euser name`

- `^[a-zA-Z][a-zA-Z0-9]*\.[a-zA-Z0-9]+$`
Dit zijn de `lgcodes` met expliciete namespace vermelding. Deze vorm is veel restrictiever in de identifiers die worden aanvaard. Dit maakt het mogelijk om `lgcodes` te gebruiken in templates en in code.

Voorbeeld: `mitem.cgbibrec`

- `^[a-zA-Z][a-zA-Z0-9]*\.$`
Dit is een verwoording van een namespace zelf. Namespaces worden zelden verwoord, maar het is wel mogelijk.

Voorbeeld: `mitem.`

- `^[a-zA-Z][a-zA-Z0-9]*\.[a-zA-Z0-9]\.scope$`
Met een `lgcode` kan ook een `scope` (in diverse talen) worden geassocieerd. `lgcodes` die eindigen op `.scope` zijn geen echte `lgcodes`: ze verwijzen naar de diverse scope notes. Enkel `lgcodes` met een namespace die verschilt van `brocade` kunnen een `scope` hebben.

Voorbeeld: `mitem.cgbibrec.scope`

Tekstfragmenten uit `*.l` files worden, als onderdeel van het Brocade installatieproces, gedefinieerd. Deze tekstfragmenten worden ook vertaald.

De Brocade toepassing heeft een faciliteit om deze tekstfragmenten aan te vullen met lokaal gedefinieerde fragmenten. Deze worden echter niet betrokken in het onderhoudsproces van de software (en dus ook niet vertaald).

Tekstfragmenten die *niet* tot de `brocade` namespace behoren, mogen ook worden aangepast. Hou er echter mee rekening dat het installatieproces de veranderde waarden gaat overschrijven met de originele gegevens. Er bestaat echter een vlag waarmee men - per tekstfragment - dit overschrijven kan verhinderen.



## Dialoogtalen

Elke Brocade installatie kan de software aanbieden in verschillende *talen*. Deze talen worden gekenmerkt door een hoofdletter.

Voorbeelden:

- `N`: Nederlands
- `E`: Engels
- `F`: Frans
- `D`: Duits
- `U`: Universeel

We spreken van `dialoogtalen` omdat deze talen niet noodzakelijk hoeven te staan voor een officiële taal. Het kunnen ook gewoon varianten zijn: voorbeeld een taal met een terminologie die beter is geschikt voor openbare bibliotheken.

Binnen een gegeven Brocade proces, deduceert de software wat de dialoogtaal is volgens een watervalsysteem.

- de dialoogtaal wordt expliciet opgegeven

- de dialoogtaal wordt teruggevonden in de universele M variabele `UDlg`. De waarde van deze variabele wordt bepaald bij het
inlog/authenticatieproces door de actuele gebruiker.

- bij installatie van Brocade wordt er een *default* taal gespecificeerd in de registry `language-default`.

In heel wat toepassingen waar een tekstfragment moet worden vertaald, is - indien de vertaling niet bestaat in de geprefereerde dialoogtaal - men ook best tevreden met een *tweede beste vertaling*. De volgorde der talen waarin er wordt gezocht naar een vertaling wordt bepaald door de registry waarde `language-sequence` (deze `language-sequence` wordt steeds vooraan aangevuld met de dialoogtaal).

## Gebruik in M

In de M omgeving kan de omzetting van een tekstfragment naar zijn vertaling gebeuren via de macro `m4_sayText` en `m4_sayScope`


## Gebruik in andere code

In code kan een tekstfragment worden ingebed door middel van de volgende structuur: `l4_<lg><fn>_<lgcode>`

We beschrijven de 3 onderdelen:

- `<lg>`

Dit is steeds één der dialoogtalen `N`, `E`, `D`, `F`, `U`. Dit element is steeds een hoofdletter en steeds aanwezig.

- `<fn>`

Dit element is ofwel afwezig, ofwel één der volgende waarden: `php`, `js`, `py`, `xml`. De code duidt een transformatie aan.

- `<lgcode>`
Dit is een tekstfragment van de gedaante `[a-zA-Z0-9]+`.

De structuur `l4_<lg><fn>_<lgcode>` wordt nu als volgt vervangen:

- het tekstfragment `<lgcode>` wordt opgezocht. Indien het *niet* bestaat wordt het *niet* vervangen en stopt deze procedure.

- de verwoording van `<lgcode>` in de dialoogtaal `<lg>` wordt opgezocht (kan leeg zijn)

- Indien `<fn>` verschillend van leeg is, dan wordt er een transformatie uitgevoerd op de verwoording van de code:

* `php`: deze transformatie zorgt ervoor dat in PHP, `"l4_<lg>php_<lgcode>"` een geldige `literal` blijft na substitutie.

* `py`: deze transformatie zorgt ervoor dat in Py2 en Py3, `"l4_<lg>py_<lgcode>"` en `'l4_<lg>py_<lgcode>'` geldige `literals` blijft na substitutie. Deze stringliterals mogen echter niet voorafgegaan worden gegaan door de `r` prefix (voor raw strings)

* `js`: deze transformatie zorgt ervoor dat in JS, `"l4_<lg>js_<lgcode>"` en `'l4_<lg>js_<lgcode>'` geldige stringliterals blijven na substitutie.

* `xml`: deze transformatie zorgt ervoor dat in een XML of een HTML instance, `"l4_<lg>xml_<lgcode>"`, `'l4_<lg>xml_<lgcode>'`een geldige attribuut waarde blijft na substitutie. Ook in `#PCDATA` en niet voorafgegaan door `&` mogen deze constructies worden gebruikt.

Voorbeelden:

```python
lgcode
lgcode doubt:
N: «I'm doubting»
```

```python

# python
text1 = "l4_Npy_doubt"
text2 = 'l4_Npy_doubt'
```

```php

// PHP
$text = "l4_Nphp_doubt"
```

```javascript

// Javascript
var text1 = "l4_Njs_doubt"
var text2 = 'l4_Njs_doubt'
```

```xml
<!-- XML -->
<br data-title='l4_Nxml_doubt' />
```

# Gebruik in templatesNG

Stel dat de volgende codes gedefinieerd zijn::

```python
lgcode titel:
N: Titel

lgcode take.infoselectsys:
N: Kies het passende bestelsysteem

lgcode takelh.infoselectsys:
N: Kies uit de bestelsystemen van het Letterenhuis
```

- `$.titel`

wordt `Titel`

- `$brocade.titel`

wordt `Titel`

- `$take.infoselectsys`

wordt `Kies het passende bestelsysteem`

- `$takelh.take.infoselectsys`

wordt `Kies uit de bestelsystemen van het Letterenhuis`

## Attributen van een `lgcode`

Een `lgcode` kan de volgende attributen hebben:

- `N`, `E`, `D`, `F`, `U`

De waarde bij het attribuut is steeds de corresponderende vertaling. Multiline waarden worden steeds tussen `«` en `»` geplaatst. `«` en `»` kunnen ook worden gebruikt om whitespace te beschermen.

- `alias`

De `lgcode` kan een `alias` zijn voor een andere `lgcode` (de waarde bij dit attribuut). Indien het `alias` attribuut optreedt, dan is het meteen ook het enige attribuut: alle attributen worden immers geërfd (ook de scope!)

- `encoding`

De vertalingen worden steeds gespecificeerd in `UTF-8`. Met het `encoding` attribuut op te geven, kan met een andere codec vastleggen. Hier zijn wel restricties aan verbonden: de verwoording moet in ASCII zijn. De enige `encoding` die wordt geaccepteerd is `xml`. Deze codec gaat niet ASCII omvormen naar entiteiten. De `encoding` wordt enkel gebruikt om de inhoud van de vertalingen vast te leggen. Verder spelen deze geen rol in Brocade

- `nature`

Hiermee kan men aangeven wat de *natuur* is van de verwoording. Er zijn 3 naturen voorzien:

- `markdown`: de vertalingen zijn in markdown
- `html`: de vertalingen stellen HTML fragmenten voor
- `text`: de default waarde

De natuur van een vertaling wordt enkel gebruikt om extra testen uit te voeren op de vertalingen zelf: zo kan bijvoorbeeld worden gecontroleerd of de markdown geldig is.

De diverse vertalingen van de *scopes* zijn evengoed attributen van de `lgcode` maar worden - voor pragmatische redenen - onder een andere identifier geplaatst. Er zijn wel een aantal aanpassingen:

- `alias` komt niet voor bij scopes
- een `alias` mag niet verwijzen naar een scope
- de default waarde voor `nature` is `markdown`

# Structuur van `*.l` files

Deze files groeperen `lgcodes`. Ze hebben een aantal eigenschappen:

- Ze beginnen met een *preamble*: deze vertelt wat de `lgcodes` in de file gemeenschappelijk hebben.
Deze preamble staat tussen een paar `"""` of beginnen met `//`

- Elke nieuwe `lgcode` begint met het vaste woord `lgcode ` op een nieuwe lijn. Vervolgens komt de identifier. Deze wordt afgesloten met een `:`.

- De diverse attributen beginnen steeds op een nieuwe lijn. Ze worden voorafgegaan door whitespace en gevolgd door een `:`. De waarde van het attribuut wordt steeds ontdaan van beginnende/eindigende whitespace. Indien deze whitespace toch betekenisvol is, of de waarde zich uitstrekt over meerdere lijnen, dan wordt de waarde aan het begin afgebakend door `«` (of: `⟦`)en op het einde door `»` (of: `⟧`).

- `*.l` files zijn steeds UTF8 gecodeerd en zonder BOM

- De `end-of-line` conventie is deze van UNIX.

Er zijn ook nog 2 speciale constructies:

- `r4_<regkey>` in de vertalingen: `<regkey>` wordt opgezocht in de registry en de constructie wordt vervangen door de waarde in de registry. Bestaat de waarde niet, dan wordt de constructie niet vervangen.

- `l4_<lgcode>` in de vertalingen: bij het gebruik van het actuele tekstfragment, worden de vertalingen opgezocht van `<lgcode>` en deze vervangen door de gegeven constructie. Deze constructie laat dus toe om `lgcodes` in te bedden in andere `lgcodes`. De `<lgcode>` moet van het type `[a-zA-Z0-9]+` zijn. Dit betekent nog dat de namespace van deze vervangers enkel `brocade` is.

Voorbeelden van `lgcodes` in een `*.l` file:

```bash
lgcode warningnumbers:
N: «Opgelet ! Er staan cijfers in de auteursnaam en dit is GEEN authority code»
E: «Note! There are numbers in the author name and this is
NOT an authority code»
F: «Attention ! Le nom d'auteur contient des chiffres et il ne s'agit PAS
d'une notice d'autorité»

lgcode metaColsys.:
N: «Systemen voor collectiebeschrijvingen»

lgcode metaColsys.docstore:
N: «Docstore omgeving»

lgcode metaColsys.docstore.scope:
N: «In deze docstore omgeving worden allerlei vaste documenten
(of URLs) geplaatst die betrekking hebben op dit collectiesysteem.
Voorbeelden zijn documenten die de toegang beschrijven tot de collectie»
```
