---
title: "Interludium: JSONPath"
date: 2020-08-06T16:56:55+02:00
featured_image: "/images/jsonpath.svg"
---

Het zoeken in tabulaire data hebben we aardig onder knie: einde jaren '70, begin jaren '80, zagen we de ene query taal na de andere verschijnen. Op het einde van de rit bleef er [SQL](https://en.wikipedia.org/wiki/SQL) over. Niet dat er geen valabele alternatieven bestonden! Ik studeerde toen informatica en herinner me maar al te goed dat er nog heel wat andere kandidaten bestonden. Maar in het evenwicht tussen kracht en eenvoud, wist dit IBM geesteskind de gulden middenweg te vinden.

Tabulaire data is zeker belangrijk. Maar het is mijns inziens niet de natuurlijke manier om data te ordenen: hiërarchische structuren lijken veel beter aan te sluiten bij hoe mensen kijken naar data. Een bibliotheek bevat boeken, boeken bevat hoofdstukken met paragrafen en deze bestaan dan weer uit zinnen.

Talen zoals [XML](https://en.wikipedia.org/wiki/XML) gaan voluit voor deze hiërarchieën. De laatste jaren is er een nieuwkomer zich ook gaat toeleggen op dit soort van data:[JSON](https://en.wikipedia.org/wiki/JSON) werd immens populair. Dit heeft alles te maken met zijn (ogenschijnlijke) eenvoud. Je kan er niet omheen: je bent veel sneller op weg met JSON dan met XML. De [specificatie](https://www.json.org) vult amper het scherm van een monitor.

Echter - het lijkt wel onontkoombaar - JSON verliest stilaan zijn status van 'eenvoud': er bestaan ondertussen 3 standaardisatie initiatieven en er bestaan niet minder dan 25 RFCs met 'JSON' in de titel.

Je merkt het ook aan de tooling rondom JSON en ik heb het dan niet over de faciliteiten ingebouwd in moderne programmeertalen. Zo hebben we [JSON schema](https://json-schema.org/), de tegenhanger van [XML Schema](https://en.wikipedia.org/wiki/XML_Schema_(W3C)).

Wat veel moeilijker is bij hiërarchische data dan bij tabulaire data, is het zoeken naar gekwalificeerde informatie. Zo werd voor XML, [XPath](https://en.wikipedia.org/wiki/XPath) ontwikkeld en ja, nu is er ook een dergelijk instrument gemaakt voor JSON.

De [oorspronkelijk tekst](https://goessner.net/articles/JsonPath/) die `JSONPath` introduceerde, kan je vinden bij Stefan Goessner. Dit was zeker niet de enige poging om een XPath-alike te construeren maar Goessner deed het voortreffelijk: een toegankelijke, doch rigoureuze specificatie gekoppeld aan implementaties in de twee belangrijkste programmeertalen op het Web: [Javascript](https://en.wikipedia.org/wiki/JavaScript) en [PHP](https://en.wikipedia.org/wiki/PHP). Beiden trouwens ook in gebruik in Brocade.

Het volgende voorbeeld heb ik geleend bij [SMARTBEAR](https://support.smartbear.com/readyapi/docs/testing/jsonpath-reference.html). Samen met [`JSONPath` online evaluator](https://jsonpath.com/), overigens een uitstekende site om je te bekwamen in `JSONPath`.

Stel, je hebt de volgende data:

```JSON
{
  "store": {
    "book": [
      {
        "category": "history",
        "author": "Arnold Joseph Toynbee",
        "title": "A Study of History",
        "price": 5.50
      },
      {
        "category": "poem",
        "author": "Aneirin",
        "title": "Y Gododdin",
        "price": 17.00
      },
      {
        "category": "fiction",
        "author": "James Joyce",
        "title": "Finnegans Wake",
        "isbn": "9788804677628",
        "price": 15.99
      },
      {
        "category": "fiction",
        "author": "Emily Bronte",
        "title": "Wuthering Heights",
        "isbn": "0-486-29256-8",
        "price": 3.30
      }
    ],
    "bicycle": {
      "color": "purple",
      "price": 25.45
    }
  },
  "expensive": 10
}
```

Deze data vertelt je welke boeken er in de winkel liggen.

Stel je wil enkel de titels hebben van alle boeken.

De selectie met behulp van de volgende JSONpath doet precies dat:
(Oefen op [`JSONPath` online evaluator](https://jsonpath.com/))

```
$.store.book[:].title
```

```JSON
[
    "A Study of History",
    "Y Gododdin",
    "Finnegans Wake",
    "Wuthering Heights"
]
```

Als je enkel fictie wil, gebruik je:
```
$.store.book[?(@.category == 'fiction')].title
```

```JSON
[
    "Finnegans Wake",
    "Wuthering Heights"
]
```

Ik denk dat je nu wel een goed idee hebt over wat de doelstellingen en de mogelijkheden zijn van `JSONPath`.

