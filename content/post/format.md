---
title: "Format"
date: 2020-08-02T13:23:14+02:00
featured_image: "/images/format.svg"
---

*Formatter* en *linters* worden nogal eens verward. Nochtans zijn ze essentieel verschillend: een linter verandert zelf de source code niet maar meldt waar er ergens iets schort. Een formatter gaat de code verfraaien zonder de betekenis te veranderen.

In middens van software ontwikkelaars zijn er 2 dingen waarmee je snel een heilige oorlog kunt ontketenen: editors en formatters. Met de komst van `Go` lijkt hier een abrupt einde aan gekomen: de designers - Turing Award winners - gebruiken een gezagsargument en zeggen: Go code moet er zo uitzien. Meer nog, het instrumentarium bekrachtigt deze visie en formatteert zonder toestemming te vragen.

`QtechNG` volgt deze aanpak, ten minste wat de gespecialiseerde formaten, X-files, D-files, L-files, B-files, I-files en M-files, betreft.

Formatters moeten worden geïntegreerd met editors (zoals `vscode`) en spelen zich dus af op file niveau, op het werkstation van de ontwikkelaars.

De aanpak die ~QtechNG` volgt, is steeds dezelfde:

- Eerst wordt het bestand onderworpen aan een linter
- Zijn er problemen, dan stopt het proces!
- Vervolgens worden - indien opportuun - de verschillende onderdelen van de bestanden gesorteerd:

    * In `L-files` worden tekstfragmenten en scopes bij elkaar gebracht. verder wordt de volgorde van het originele bestand gerespecteerd.
    * In `D-files` worden `m4_get`, `m4_set`, `m4_del` en `m4_upd` bij elkaar gebracht en verder wordt de volgorde van het originele bestand gerespecteerd.

- Na het sorteren worden de diverse lijnen en onderdelen van het bestand passend geformatteerd

