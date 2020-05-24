---
title: "Cobra"
date: 2020-05-24T11:03:36+02:00
featured_image: "/images/cobra.svg"
---


Als je een goede [CLI](https://en.wikipedia.org/wiki/Command-line_interface "Command Line Interface") wil bouwen, moet je op zoek naar een goed framewerk.

Voor onze in-house `Python` code hebben we `Toolcat` maar voor een software gebaseerd op `Go` hadden we nog niet iets dergelijks.

Een paar jaar geleden volgen Luc en ik een tutorial over Go: het was een duizelingwekkende ervaring aan sneltrein-tempo gegeven door Steve Francia.
Deze man werkt voor Google en was rechtstreeks betrokken bij het Go-project. Zijn taak was daarbij niet zozeer het implementeren van Go. Neen, hij moest zorgen voor een aantal instrumenten zodanig dat ontwikkelaars binnen Google snel aan de slag konden met Go.

Hij vervaardigde verschillende outstanding libraries en softwares, allen gebaseerd op Go.

Zo maakte hij [Hugo](https://gohugo.io/ "Hugo"), een generator voor statische websites. Deze blog is bijvoorbeeld gemaakt met Hugo. Hugo ontpopte zich ondertussen als één van de meest populaire web builders.

Zijn meest populaire product is echter het duo [Cobra/Viper](https://github.com/spf13/cobra "Cobra/Viper"). Cobra is een framewerk om CLI's te maken. Viper is dan weer een interactieve tool die hierbij kan helpen.

Cobra is simpelweg het meest gebruikte CLI-framewerk in de Go-wereld: Hugo en Kubernetes zijn maar een paar producten die hiermee gebouwd zijn.

De redenen van het succes van Cobra zijn velerlei:

- in de eerste plaats is er de kwaliteit van de code: Cobra is simpelweg een tutorial voor Go
- Cobra is platform onafhankelijk
- De software is zeer flexibel en opgewassen tegen alle taken die je er kunt tegen aan gooien
- De software gaat verder dan mogelijk maken van commando's: help en documentatie worden automatische gegeneerd en in allerlei formaten
- Aangemaakte software is POSIX-compliant

Cobra is zeker een goede kandidaat om er `qtechng` mee te vervaardigen.

Ik heb ondertussen verschillende CLI's gemaakt met `Cobra`. Een goed voorbeeld is `Qq`. `Qq` is een voorloper van `qtechng`.


```bash

/home/rphilips/Desktop$ Qq
Qq maintains the Brocade software:

    - Development
    - Installation
    - Deployment
    - Version Control
        - Management

Usage:
  Qq [command]

Available Commands:
  about       Useful information about `Qq`
  help        Help about any command
  project     Project functions
  system      System information
  version     Version functions

Flags:
      --cwd string         working directory
      --directory string   qpath of a directory under a project
      --editor string      editor name
      --force              with force
  -h, --help               help for Qq
      --info               lists arguments, flags and global values
      --jq string          jq command
      --lower              transforms to lowercase
      --pattern string     Posix glob pattern
      --project string     project to work with
      --recurse            recursively walks through directory and subdirectories
      --regexp             searches as a regular expression
      --remote             execute on the remote server
      --tree               handles filenames as rpaths in the project
      --uid string         user id
      --unhex .            unhexify the arguments starting with .
      --verbose            verbose output (default true)
      --version string     version to work with

Use "Qq [command] --help" for more information about a command.
```

Een paar voorbeelden om te werken met de CLI:

```shell
Qq project create /take/application --version=5.10
Qq project list /take/*
```

Het programmeren zelf is descriptief. Om bijvoorbeeld `Qq project create` te maken is het voldoende om in de code de volgende beschrijving te plaatsen:

```go
var projectListCmd = &cobra.Command{
	Use:     "list",
	Short:   "List projects",
	Long:    `Command lists all project matching a given pattern`,
	Args:    cobra.MaximumNArgs(1),
	Example: "Qq project list /stdlib/t*",
	RunE:    projectList,
	PreRun:  func(cmd *cobra.Command, args []string) { preSSH(cmd) },
	Annotations: map[string]string{
		"remote-allowed":    "yes",
		"always-remote-onW": "yes",
		"fill-version":      "yes",
		"with-QtechType":    "BW",
	},
}
```
De `PreRun` en de `Annotations` zijn nog wat verwarrend maar daarover later meer!










