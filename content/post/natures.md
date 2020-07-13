---
title: "Naturen"
date: 2020-07-13T16:11:09+02:00
featured_image: "/images/nature.svg"
---

Met QtechNG wordt er ook een classificatie van de bestanden geïntroduceerd.

Dit is in feite een formalisering van wat reeds jaar en dag gebruikt wordt door het ontwikkelteam.

Een bestand kan meerdere naturen hebben.

Deze naturen hebben verschillende functies:

- ze sturen de installatie
- ze zijn belangrijk voor m4/r4/i4 substitutie
- ze kunnen worden gebruikt bij `queries`

## `binary` en `text`

Deze naturen sluiten elkaar uit. Standaard wordt elk bestand als `text` beschouwd. Enkel het corresponderend configuratiebestand (`brocade.json`) kan door middel van de parameter `binary` sommige bestanden als binair markeren.

## `config`, `install`, `release`, `check`

Elk project heeft juist 1 configuratiebestand (`brocade.json`). Dit bestand heeft de natuur `config` (en `text`).

In dezelfde directory als het configuratiebestand kunnen zich ook de `Python` scripts

- `install.py` (natuur: `install` + `text`)
- `release.py` (natuur: `release` + `text`)
- `check.py` (natuur: `check` + `text`)

bevinden. De werking en de betekenis van deze bestanden worden later uitvoerig behandeld.

## `bfile`, `dfile`, `ifile`, `lfile`, `mfile`, `xfile`

Bestanden die de natuur `text` hebben en die niet voorkomen in het lijstje bestanden bepaald door de parameter `notbrocade` uit de configuratiefile, kunnen gekarakteriseerd worden door hun extensie:
de bestanden met extensie `*.b`, `*.d`, `*.i`, `*.l`, `*.m`, `*.x` krijgen een corresponderende natuur.

## `auto`, `objectfile`

Bestanden met natuur `dfile`, `lfile`, `ifile` krijgen ook nog eens de natuur `objectfile` mee.

Bestanden met natuur `bfile`, `dfile`, `ifile`, `lfile`, `mfile` of `xfile` zijn ook van natuur `auto`.
