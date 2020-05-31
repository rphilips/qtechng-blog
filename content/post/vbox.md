---
title: "Vbox"
featured_image: "/images/vbox.svg"
date: 2020-05-27T11:51:32+02:00
---
Een [virtuele machine](https://en.wikipedia.org/wiki/Virtual_machine "Virtual Machine") of [Docker](https://en.wikipedia.org/wiki/Docker_(software) "Docker") ?

`qtechng` werkt essentieel steeds met 2 servers waarbij de ene machine de ontwikkelmachine (dev.anet.be: qtechtype == 'B') is en de andere ofwel je werkstation (qtechtype == 'W') ofwel een productiemachine (qtechtype == 'P').

Dat betekent dat je voor de ontwikkeling van `qtechng` ook moet kunnen beschikken over 2 machines. De aangewezen oplossing hiervoor is om op je werkstation ofwel een *virtual machine* ofwel een *docker container* op te zetten.

Ik koos ervoor om te gaan voor de `virtual machine`. Deze keuze is niet zo vanzelfsprekend: Docker is immers *gemaakt* om dit soort setups te tackelen. Ik ben echter meer vertrouwd met *virtual machines*. Bovendien wil ik zo dicht mogelijk aanleunen bij de situaties waarin `qtechng` worden ontplooid.

Er zijn echter ook nog wat andere redenen: ik wil graag eens een aantal Linux versies uitproberen waarover ik veel goeds heb gehoord maar er zelf nooit heb mee gewerkt: Manjaro, Ubuntu Budgie en UbuntuDDE.

Één van de mooie dingen van een VM is dat je ook kunt experimenteren met het aantal CPU's (cores) die je toewijst aan een VM.

Het opzetten van een VM aan de hand van Virtual Box is niet bepaald uitdagend. Toch een wijze raad: moderne Linux distributies komen met een software store. Het voorkomt heel wat problemen als je *Virtual Box* installeert vanuit deze software store: nieuwere versies vertonen immers vaak compatibiliteitsproblemen.

Vanzelfsprekend mag je niet nalaten de `Guest Additions` te installeren: deze maken het werken met muis, clipboard en  het filesysteem een stuk gemakkelijker.

Voor wat netwerking betreft, kies ik voor de eenvoudigste en tegelijkertijd ook veiligste oplossing: `NAT` met Port-forwarding voor `SSH`.

- Mijn host (dagdagelijkse machine) is Linux Mint
- De `guest` die ik installeer is `Ubuntu Budgie` (20.04)
- Met Linux `Guest Additions`
- Networking: NAT met Port Forwarding: SSH: IP 127.0.0.1 op poort 2222 naar poort 22 op de guest
- In /etc/hosts op de host plaats ik een entry: `127.0.0.1       localhost budgie`. Op deze wijze kan ik mijn `guest` steeds adresseren als `budgie`.

Op `budgie` installeer ik de environment variabele `BROCADE_REGISTRY` in `etc/environment`:

```bash
BROCADE_REGISTRY=/home/rphilips/brocade/registry.json
```

De relevante inhoud van de registry:

```json
{
    "qtechng-test": "test-entry",
    "qtechng-version": "9.92",
    "qtechng-hg-backup": "ssh://root@backup.anet.be//qtech/hg/{version}",
    "qtechng-type": "B",
    "qtechng-repository-dir": "/home/rphilips/qtechng",
    "qtechng-hg-enable": "1",
    "qtechng-max-openfiles": "64"
}
```

Aangezien `budgie` de rol gaat spelen van de ontwikkelserver moet hier een `SSH` service worden op gedefinieerd.

`Ubuntu` is een [SystemD](https://en.wikipedia.org/wiki/Systemd "SystemD") distributie en bijgevolg is het opzetten en starten van de `SSH` service vrij standaard:

```bash
sudo apt-get install openssh-server  # installeren van de software uit de softare store
sudo systemctl enable ssh # enable de service
sudo systemctl start ssh # opstarten van de start
sudo ufw allow ssh # firewall configuratie
sudo ufw enable
sudo systemctl status ssh
```

Vanzelfsprekend moet je nu een account aanmaken op `budgie`.

Vervolgens moet je je SSH gegevens kopieren naar `budie`. Is je host een  UNIX-achtige machine, dan kan je dit meer dan waarschijnlijk eenvoudig doen door middel van de instructie:

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub rphilips@budgie -p 2222 # Voer uit van op je eigen machine
```

Op de host (je eigen werkstation) zien de relevante registry waarden er als volgt uit:

```json
{
    "qtechng-releases": "4.20; 4.30; 4.40; 5.00; 5.10",
    "qtechng-test": "test-entry",
    "qtechng-diff": "[\"meld\", \"$target\", \"$source\"]",
    "qtechng-version": "9.92",
    "qtechng-uid": "rphilips",
    "qtechng-editor-exe": "code",
    "qtechng-server": "budgie:2222",
    "qtechng-type": "W",
    "qtechng-workstation-basedir": "/home/rphilips/projects/brocade/edit",
    "qtechng-max-openfiles": "64"
}
```

Let op de adressering van de server!

Zo, we hebben nu twee systemen klaar voor actie!
