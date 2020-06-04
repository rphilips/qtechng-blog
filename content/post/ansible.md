---
title: "Ansible Automation Platform en Qtech"
date: 2020-06-03T10:50:56+02:00
featured_image: "/images/ansible.svg"
---

Deze blog-post van Luc gaat over het beheer van [Ansible](https://www.ansible.com) met *Qtech(ng)*.  

In 2016 hebben wij de afweging gemaakt tussen *Salt* en *Ansible* voor IT-automatisering.  Salt leek op dat moment de beste keuze.  De software had een lage leercurve en enorm veel integraties.  Ansible daarentegen was toen de “new kid on the block” maar wel met veel potentieel !

Intussen heeft Ansible onder de vleugels van [Red Hat](www.redhat.com) een inhaalbeweging gemaakt en is vooral dankzij support van Red Hat **het** automatiseringsplatform geworden.   

Wat heeft dan voor ons de doorslag gegeven om over te stappen ?

Ansible heeft een aantal eigenschappen die het mogelijk maken om het beheer van *Ansible draaiboeken* en *Ansible roles* onder Qtech te plaatsen.  
Dit was met Salt niet of nauwelijks realiseerbaar of toch niet zonder in te grijpen in de manier waarop Qtech werkt.  

Nu, vooraleer we dieper ingaan in de ontplooing van een Ansible folderstructuur op onze servers met Qtech,
toch eerst even een woordje uitleg over het gebruik van Ansible zelf en wat onze doelstellingen zijn.  

- De [Ansible Software](https://www.ansible.com) wordt op al onze servers geinstalleerd.

- De installatie van de Ansible folderstructuur gebeurt door Qtech.

- Op elk van onze servers wordt een Ansible folderstructuur geplaatst.  Dit zijn de *Ansible playbooks* en de *Ansible roles* afgestemd voor die specifieke server. 

- De uiteindelijke installatie van software en services op onze servers start met het Ansible commando:  

```bash
ansible-playbook playbook.yml 
```

- De opdrachten in een Ansible draaiboek zijn idempotent en kunnen meermaals uitgevoerd worden zonder neveneffecten.   

De Ansible folderstructuur op een server ziet er als volgt uit:

```
* playbook.yml
* playbook-gtm.yml
* playbook-apache.yml
* ...
* files/
  * gtm.tar.gz
  * apache.tar.gz
  * ...
* group_vars
  * all/
    * role-common.yml
    * role-make.yml
    * role-gtm.yml
    * role-apache.yml
    * ...
* roles/
  * gtm/
    * handlers/
      * main.yml
      * ...
    * meta/
      * main.yml
      * ...
    * tasks/
      * main.yml
      * ...
    * templates/
      * execcache.j2
      * ...
  * apache/
  * htmldoc/
  * ...
```

Deze Ansible folderstructuur is vrij eenvoudig aan te maken met Qtech indien een aantal afspraken rond *Qtech bestandsnamen* en *Qtech folders* worden gevolgd. 

De Qtech repository voor Ansible ziet er als volgt uit:

```
* /ansible/
  * roles/
    * gtm/
      * install.py
      * task-main.yml
      * meta.yml
      * handler-main.yml
      * plugins.xc.j2
      * ...
    * apache/
    * ...
  * servers/
    * presto/
      * install.py
      * playbook.yml
      * vars-common.yml
      * vars-apache.yml
      * vars-gtm.yml
      * ...
    * moto/
    * dolce/
    * ...
```

- *Roles* worden beheerd in Qtech projecten `'/ansible/roles/[role name]'`  
- Voor elke server bestaat een Qtech project `'/ansible/servers/[server name]'`    
- Het Qtech bestand `'/ansible/servers/[server name]/playbook.yml'` wordt vertaald naar een server *Ansible draaiboek* 
- Qtech bestanden `'/ansible/servers/[server name]/vars-*.yml'` worden vertaald naar *Ansible variabelen* in `'group_vars/all/'`
- Qtech bestanden `'/ansible/roles/[role name]/task-*.yml'` worden vertaald naar *Ansible taken*  
- Het Qtech bestand `'/ansible/roles/[role name]/meta.yml'` wordt vertaald naar *Ansible meta data*  
- Qtech bestanden `'/ansible/roles/[role name]/handler-*.yml'` worden vertaald naar *Ansible handlers*
- Qtech bestanden `'/ansible/roles/[role name]/*.j2'` worden vertaald naar *Ansible templates*
- ...




Uiteindelijk is het `'/core/python3/ansible.py'` die de vertaalslag doet van Qtech bestanden naar een Ansible folderstructuur.  

bv. `'/ansible/servers/presto/install.py'`

```python
# -*- coding: utf-8 -*-
# /ansible/servers/presto/install.py

from anet.core import ansible
ansible.install_playground(host='presto')
```

bv. `'/ansible/roles/gtm/install.py'`

```python
# -*- coding: utf-8 -*-
# /ansible/roles/gtm/install.py

from anet.core import ansible
ansible.install_role('gtm')
```

Bij het inchecken van een Ansible Qtech project worden ook de bestanden uit de Ansible repository (een remote site bepaald door een registry-waarde) gekopieerd naar de Ansible folderstructuur.  Dit gaat voornamelijk over bestanden die niet thuishoren in Qtech zoals tarbals, zip, e.a.  Op die manier is alles aan boord en is in principe geen netwerktoegang vereist tijdens de installatie en configuratie van de server.

Je voelt het “kip-en-het-ei-verhaal” al aankomen ?  Hoe kan je nu een Ansible folderstructuur opbouwen op een server waarop nog geen Qtech aanwezig is ?  bv. een installatie op een nieuwe server.

Wel, op de ontwikkelserver (de server met system-role **'dev'**) wordt bij het inchecken van een Ansible Qtech project, voor **elke** server een Ansible folderstructuur opgebouwd.   De nieuwe server kan dan geinstalleerd en geconfigureerd worden ofwel vanaf de ontwikkelserver ofwel na kopiëren van de Ansible folderstructuur naar de nieuwe server.  De keuze is aan ons.
