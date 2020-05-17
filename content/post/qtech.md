---
title: "[mlq]tech(ng)?"
date: 2020-05-17T13:23:43+02:00
featured_image: "/images/toolkit.svg"
---

mtech/ltech/qtech/qtechng is het **beheersinstrument** van de Brocade software.

Al heel snel bleek dat we een adequaat instrument nodig hadden om de bibliotheeksoftware te beheren. Dit was al zo in het begin van de jaren '90 toen we nog automatiseerden met Vubis. 

Ook in die dagen hadden we al heel wat software die eigen was aan de Universiteit Antwerpen en de bibliotheken die toen deel uitmaakten van Vubis Antwerpen: er was natuurlijk het Impala project met VirLib, Agrippa (onze archiefsoftware). Ook de deelname aan Europese projecten legden eisen op aan de software die nog moeilijk handmatig konden worden ingevuld.

# Taken opgenomen door qtech

Beheersen van software betekent in onze context verschillende dingen:

- Hulp tijdens het ontwikkelproces
- Integriteit van het code repository bewaken
- Samenwerking mogelijk maken
- Eenvoudige ontplooiing op diverse servers
- Administratieve en beheersmatige informatie verschaffen


## Hulp tijdens het ontwikkelproces

Het staat ontwikkelaars vrij om hun ontwikkeltools te kiezen. Er zijn ondertussen verschillende programmer's editors de revue gepasseerd: Crisp, Brief, Emacs, XEmacs, Textadept, Sublime Text, Visual Studio Code. Maar ook meer geavanceerde instrumenten zoals Eclipse en Netbeans werden (kort) gebruikt in het ontwikkelproces. 

De verscheidenheid aan technologieën, de diverse OS waarop ontwikkelaars werken samen met hun persoonlijkheid zorgt ervoor dat er geopteerd wordt voor eerder eenvoudige tools waarvan hun functionaliteit dan wordt aangevuld met behulp van extensies. Visual Studio Code is daar een goed voorbeeld van. 10 speciaal ontworpen extensies zorgen ervoor dat de Brocade specifieke bestanden snel kunnen worden opgespoord en bewerkt.


## Integriteit van het code repository

Qtech moet ervoor zorgen dat de integriteit en de eenheid van de software duidelijk is: zowel voor ontwikkelaars als voor het management. De software is *niet* OpenSource en zorgt voor een belangrijke bron van inkomsten voor de Universiteit Antwerpen en haar bibliotheek.

## Samenwerking mogelijk maken

Er werken diverse mensen samen aan het software repository. Het zijn niet allemaal ontwikkelaar en ze spelen allemaal een belangrijke rol bij de uitbouw van Brocade: aanpassen van verwoordingen, opbouw van de menustructuur, vertalingen, design van webpagina's ...

Deze diverse groep moet vlot kunnen werken aan de source en niet gehinderd worden door afspraken en handelingen die ver buiten hun expertise terrein liggen.

## Eenvoudige ontplooiing op diverse servers

Installatie van major releases en bugfixes moeten gemakkelijk kunnen worden doorgetrokken naar de diverse productieservers, demo- en opleidingsservers.

Deze acties moeten zowel interactief als 'scheduled' kunnen plaatsvinden.

Installaties en updates komen soms ook met contractuele verplichtingen en moeten dus ook kunnen worden hard gemaakt in de vorm van 1 bestand (bijvoorbeeld gedeponeerd bij een notaris)


## Administratieve en beheersmatige informatie verschaffen

Er is geregeld noodzaak om te weten hoeveel aanpassingen er zijn aangebracht en door wie.

Dit gaat soms verder dan wat een versie controle systeem standaard kan aanleveren.


# Een stukje geschiedenis

De eerste versie van de software heette *mtech*. 

Deze software werd geschreven in *C* en construeerde een [Makefile](https://en.wikipedia.org/wiki/Make_(software) "Makefile"). De functionaliteit was beperkt en richtte zich tot ontwikkeling op [SCO UNIX](https://en.wikipedia.org/wiki/Santa_Cruz_Operation "SCO UNIX"). De enige bestandstypes die werden ondersteund waren Mumps files.

Er kwamen voortdurend uitbreidingen en tenslotte verscheen een tweede versie die ook gebruik maakte van [AWK](https://en.wikipedia.org/wiki/AWK "AWK"). Met deze versie kwam er ook interesse van buitenaf en *mtech* werd ook gebruikt bij tutorials en congressen rond de [Mumps programmeertaal](https://en.wikipedia.org/wiki/MUMPS "MUMPS"). In deze versie werd ook voor de eerste keer gebruik gemaakt van macro's door middel van de [m4 preprcoessor](https://en.wikipedia.org/wiki/M4_(computer_language) "m4")

Toen Vubis Antwerpen deelnam aan het HyperLib project was het onmogelijk om nog langer te blijven werken met een instrument die zich richtte op 1 soort technologie. De software werd nogmaals herwerkt maar nu in [Perl](https://en.wikipedia.org/wiki/Perl). Tevens werd ook de naam veranderd naar *ltech*. De oude naam botste immers met een populaire OpenSource tool die beschikbaar was onder Linux.

Toen Brocade eraan kwam was het weer tijd om het instrument aan te passen. Alle voorgaande versies waren gericht op file sharing: de ontwikkelaars werken op Windows workstations en deelden bestanden op de ontwikkelserver. Dit was niet langer houdbaar: [filesharing](https://en.wikipedia.org/wiki/Samba_(software) "SAMBA") veroorzaakt diverse problemen en was ook moeilijk om vanop afstand in te zetten. De software kreeg als naam *qtech* en werd ontwikkeld in [Python](https://en.wikipedia.org/wiki/Python_(programming_language) "Python"). De software werd gesofistikeerd: transport gebeurde op basis van [SSH](https://en.wikipedia.org/wiki/Secure_Shell "SSH"), er waren diverse soorten servers, projecten, registry.

In 2003 werd deze software aangevuld met *wxqtech* een GUI op basis van [wxpython](https://en.wikipedia.org/wiki/WxPython "wxpython"). Tot op de dag van vandaag gebruikt iedereen binnen Anet deze software.

Qtech werd ook voortdurend geintegreerd in geavanceerde programmer's editors.
