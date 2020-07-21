---
title: "Search"
date: 2020-07-17T19:44:58+02:00
featured_image: "/images/search.svg"
---

De meest gebruikte faciliteit van `qtech` is ongetwijfeld het zoeken in het software repository.

Dit moet nog beter (lees: sneller) worden in `QtechNG`.

De basis van de zoek-software is de volgende golang structuur:

```go
type Query struct {
    Release string
    CmpRelease string
    Patterns []string
    Natures []string
    Cu []string
    Mu []string
    CtBefore string
    CtAfter string
    MtBefore string
    MtAfter string
    ToLower bool
    Regexp bool
    PerLine bool
    Contains []string
    Any []func(qpath string, blob []byte) bool
    All []func(qpath string, blob []byte) bool
}
```

## Attributen

Elk van deze attributen stelt een specifiek type van zoeken voor. Zijn er meerdere attributen gedefinieerd, dan zijn dit **AND** searches: aan elk attribuut moet worden voldaan.

Dit impliceert ook dat - indien er meerdere attributen ingevuld zijn - de volgorde erg belangrijk wordt: sommige zoekacties vergen nu éénmaal meer resources dan andere.

Laten we even de verschillende attributen overlopen. Nadien zullen we uitleggen hoe één en ander in elkaar zit.

### Release

Indien verschillend van leeg, dan moeten zoekresultaten steeds binnen de gegeven `Release` worden gezocht.

*straight forward*, dit attribuut moet steeds gespecificeerd zijn (impliciet of expliciet).

### CmpRelease

Ook dit attribuut stelt een release voor (m.a.w. een string van de gedaante `5.10`). Een bestand komt in het zoekresultaat indien er aan één van de volgende voorwaarden wordt voldoen:

- het bestand bestaat **niet** in release CmpRelease
- het bestand verschilt van inhoud ten opzichte van release CmpRelease

### Patterns

Wat de snelheid van zoeken betreft, is dit een cruciaal attribuut: het is een lijst met wildcards. Enkel bestanden waarvan het `QtechNG` path voldoet aan één of meer van deze patronen, worden weerhouden.

Belangrijk is dat de bestanden zelf niet moeten worden ingelezen.

### Natures

In een vorige blog hebben we het al gehad over de naturen van source code. Enkel de bestanden met een natuur in deze lijst worden weerhouden.

De bestanden zelf hoeven niet te worden ingelezen. Wel de corresponderende configuratiefiles `brocade.json`. Hiervan zijn er natuurlijk heel wat minder.

### CtBefore

Hiervoor wordt de meta informatie van de betreffende source code opgehaald. Enkel indien de *creation time* kleiner of gelijk is aan CtBefore, wordt het bestand weerhouden.

De tijden worden steeds weergegeven in de vorm `YYYY-MM-DDThh:mm:ss` (ongeldige tijdstippen worden steeds genormaliseerd door overflow: vb. als hh = 25, dan schuift DD op met 1 en hh wordt 01)

### CtAfter

Hiervoor wordt de meta informatie van de betreffende source code opgehaald. Enkel indien de *creation time* groter of gelijk is aan CtBefore, wordt het bestand weerhouden.

De tijden worden steeds weergegeven in de vorm `YYYY-MM-DDThh:mm:ss` (ongeldige tijdstippen worden steeds genormaliseerd door overflow: vb. als hh = 25, dan schuift DD op met 1 en hh wordt 01)

### Cu

Is een lijstje met de userid's van de mogelijke creators. Enkel indien de daadwerkelijke creator in het lijstje zit, wordt het bestand weerhouden.

### MtBefore

Hiervoor wordt de meta informatie van de betreffende source code opgehaald. Enkel indien de *modification time* kleiner of gelijk is aan MtBefore, wordt het bestand weerhouden.

De tijden worden steeds weergegeven in de vorm `YYYY-MM-DDThh:mm:ss` (ongeldige tijdstippen worden steeds genormaliseerd door overflow: vb. als hh = 25, dan schuift DD op met 1 en hh wordt 01)

### MtAfter

Hiervoor wordt de meta informatie van de betreffende source code opgehaald. Enkel indien de *modification time* groter of gelijk is aan CtAfter, wordt het bestand weerhouden.

De tijden worden steeds weergegeven in de vorm `YYYY-MM-DDThh:mm:ss` (ongeldige tijdstippen worden steeds genormaliseerd door overflow: vb. als hh = 25, dan schuift DD op met 1 en hh wordt 01)

### Mu

Is een lijstje met de userid's van de mogelijke last modifiers. Enkel indien de daadwerkelijke modifier in het lijstje zit, wordt het bestand weerhouden.

### Contains

Dit is een lijstje met strings (`needles`). De precieze werking is afhankelijk van de waarden van `PerLine`, `ToLower` en `Regexp`.

In essentie wordt de inhoud van de bestanden gecontroleerd tegen het lijstje met needles. **ALLE** needles moeten tot het bestand behoren.

Er zijn nu diverse situaties:

- is `PerLine` waar, dan moeten alle needles in dezelfde lijn worden gevonden. Anders wordt gewoon gekeken in het bestand.

- is `Regexp` waar, dan worden de needles omgevormd tot reguliere uitdrukkingen.

- is `ToLower` waar, dan wordt de inhoud van het bestand omgezet naar kleine letters. Is `Regexp` onwaar, dan worden ook de needles omgezet naar kleine letters (met `Regexp` waar, werkt dit niet: de betekenis van de reguliere uitdrukking zou immers kunnen veranderen. vb. `\D` omzetten naar `\d`  verandert de zoekactie helemaal.)

### Any

Dit is een gespecialiseerde zoekattribuut: het attribuut is een lijst van functies. Elke functie werkt met 2 argumenten: een `QtechNG` path naam en een inhoud in bytes. Onderhuids wordt de path naam van elk bestand dat we tegenkomen, samen met zijn inhoud gegeven aan deze functies. Van zodra er 1 functie waar is, wordt het bestand geselecteerd.

### All

Dit is een gespecialiseerde zoekattribuut: het attribuut is een lijst van functies. Elke functie werkt met 2 argumenten: een `QtechNG` path naam en een inhoud in bytes. Onderhuids wordt de path naam van elk bestand dat we tegenkomen, samen met zijn inhoud gegeven aan deze functies. Enkel indien *ALLE* functies waar zijn, wordt het bestand geselecteerd.

## Uitwerking

Uit de beschikbare attributen is het duidelijk dat `Query` niet enkel is bedoeld om door een UI te worden aangestuurd: **Any** en **All** maken de software ook heel erg geschikt voor interne doeleinden.

De effectieve implementatie gebeurt geheel in termen van concurrency en pipelining.

De pipeline bevat 3 fases:

- Optimalisering van de `Query`
- in de tweede fase worden de kandidaat bestanden opgelijst
- in de derde fase wordt elke kandidaten getest tegen `Query`.

In de eerste fase wordt de `Query` zelf geanalyseerd en geoptimaliseerd: reguliere uitdrukkingen worden gecompileerd, overbodige patronen worden geschrapt en passende [Boyer-Moore skiptabellen](https://en.wikipedia.org/wiki/Boyer%E2%80%93Moore_string-search_algorithm) worden aangemaakt. Voor alle duidelijkheid: de searches - als die al bestaan - zijn niet altijd volgens Boyer-Moore. Er zijn immers nogal wat situaties waar dit te weinig zou opbrengen. De lengte van de te doorzoeken bestanden speelt hierbij de hoofdrol: bevatten deze bestanden minder dan 64 karakters dan wordt er gewoon *brute force* gezocht. Die '64' valt niet zomaar uit de lucht (en heeft ook niets te maken met het schaakspel). Diverse zoekstrategieën in de [golang code](https://golang.org/src/bytes/bytes.go?s=26077:26106#L984) zelf maken gebruik van dit getal.

In de tweede fase wordt er maximaal gebruik gemaakt van de mogelijkheden geboden door `Patterns` (en `Release`). De kandidaten worden parallel opgespoord door analyse van de QtechNG paths. 
Om sneller te werken worden in de tweede fase van de pipeline een aantal *fouten* toegelaten. 

In de derde fase wordt echter elk bestand uit de eerste fase rigoureus (en in parallel) getest tegen de *ganse* Query. Indien deze werkwijze je doet denken aan de filosofie achter het gebruik van [Bloom filters](https://en.wikipedia.org/wiki/Bloom_filter), dan zit je goed!.

## Benchmarks

Tijd voor benchmarks!

We gaan ons niet bezig houden met micro benchmarks: laten we meteen een realistisch scenario opzetten.

Ik converteerde qtech's 5.00 release naar QtechNG's 9.98. Deze conversie was compleet: sources, objecten en meta informatie.

Ik wou 3 searches uitvoeren: deze waren op zich niet zo heel moeilijk maar wel representatief voor het concrete gebruik.

### Search 1

```go
Query{
    Release: "9.98",
    Patterns: []string{"/*"},
    Contains: []string{"m4_getCatIsbdTitles"},
}
```

Deze zoekactie doorzocht alle bestanden naar de string "m4_getCatIsbdTitles".

De sublieme benchmarking van Go gaf het volgende resultaat:

```text
Running tool: /usr/local/go/bin/go test -benchmem -run=^$ brocade.be/qtechng/source -bench ^(BenchmarkQuery77)$

goos: linux
goarch: amd64
pkg: brocade.be/qtechng/source
BenchmarkQuery77-4 1000000000 0.0594 ns/op 0 B/op 0 allocs/op
PASS
ok brocade.be/qtechng/source 0.673s
```

Met andere woorden, een zoekresultaat binnen (ongeveer) een halve second.

### Search 2

```go
Query{
    Release: "9.98",
    Patterns: []string{"/*.m"},
    Contains: []string{"m4_getCatIsbdTitles"},
}
```

Deze zoekactie doorzocht alle bestanden naar de string "m4_getCatIsbdTitles" maar beperkt zich enkel tot de m-files.

```text
Running tool: /usr/local/go/bin/go test -benchmem -run=^$ brocade.be/qtechng/source -bench ^(BenchmarkQuery78)$
goos: linux
goarch: amd64
pkg: brocade.be/qtechng/source
BenchmarkQuery78-4 1000000000 0.0387 ns/op 0 B/op 0 allocs/op
PASS
ok brocade.be/qtechng/source 0.331s
```

Een halvering van het vorige zoekresultaat.


### Search 3

In de derde zoekactie willen we de bestandne opzoeken die - net zoals in de vorige zoekacties, de string "m4_getCatIsbdTitles" bevatten, maar waarvan de bestandsnaam niet voldoet aan de style guide.

Ik geef de volledige benchmarkfunctie:

```go
func BenchmarkQuery79(t *testing.B) {
	r := "9.98"

	query := &Query{
		Release:  r,
		Patterns: []string{"/*"},
		Contains: []string{"m4_getCatIsbdTitles"},
		All: [](func(qpath string, blob []byte) bool){
			func(qpath string, blob []byte) bool {
				k := strings.LastIndex(qpath, "/")
				if k == -1 {
					return false
				}
				base := qpath[k+1:]
				if len(base) < 4 {
					return false
				}
				fourth := rune(base[3])
				ok := strings.HasPrefix(base, "g") || strings.ContainsRune("wuts", fourth)
				return !ok
			},
		},
	}

	result := query.Run()

	if len(result) != 13 {
		t.Errorf("Should have found 72: %d", len(result))
		fmt.Println(query)
		for _, x := range result {
			fmt.Println(x.String())
		}
		return
	}
}
```

Deze test gaf het volgende resultaat:
```text
Running tool: /usr/local/go/bin/go test -benchmem -run=^$ brocade.be/qtechng/source -bench ^(BenchmarkQuery79)$

goos: linux
goarch: amd64
pkg: brocade.be/qtechng/source
BenchmarkQuery79-4   	1000000000	         0.0521 ns/op	       0 B/op	       0 allocs/op
PASS
ok  	brocade.be/qtechng/source	0.662s
```



### Besluit

Deze benchmarks werden verschillende keren uitgevoerd (ook met een reboot tussen de verschillende benchmarks). De resultaten waren in grote lijnen consistent.


