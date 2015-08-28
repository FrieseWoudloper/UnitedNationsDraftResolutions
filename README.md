## Achtergrond
In de week van 17 tot en met 21 augustus vond op het Geofort bij Herwijnen het [Maptime Summercamp NL 2015](http://www.meetup.com/GeoForts-sideshow-diverse-activiteiten-op-het-fort/events/223911131/) plaats. Een groep van zo'n 12 enthousiaste geo-geeks kwam bij elkaar om samen met kaarten aan de slag te gaan. Eén van de onderwerpen was het onderzoek van [Sanne Blauw](https://twitter.com/sanneblauw) van De Correspondent naar [het taalgebruik van de Verenigde Naties](https://decorrespondent.nl/3140/Help-ons-zoeken-naar-de-stopwoordjes-van-de-Verenigde-Naties/582291968280-0d2f6f09). Ze vroeg hulp bij het visualiseren van patronen: Welke onderwerpen vinden bepaalde regio's belangrijk? Welke landen steunen elkaar door dik en dun? Hoe verandert dit in de tijd? Ze maakt hierbij gebruik van de gegevens in het [United Nations Bibliographic Information System (UNBISNET)](http://unbisnet.un.org:8080/ipac20/ipac.jsp?&menu=search&aspect=power&npp=50&ipp=20&spp=20&profile=bib&index=.TW&term=%22draft+resolution%22&index=.AW&term=Netherlands).

## Metadata van draft resoluties van Nederland
Mijn insteek was om de metadata van de draft resoluties te verzamelen voor verdere analyse. Daarbij heb ik mij beperkt tot draft resoluties die door Nederland zijn geschreven of waaraan Nederland heeft bijgedragen. 
UNBISNET biedt helaas niet de mogelijk om de metadata in een gestructureerd formaat te downloaden of via een API eenvoudig op te vragen. Ik heb daarom in R een script geschreven dat de zoekfunctionaliteit op de website gebruikt om de metadata te scrapen. Het script [un-draft-resolutions.R](https://github.com/FrieseWoudloper/un-draft-resolutions/blob/master/un-draft-resolutions.R) en de uitvoer staan in deze GitHub-repository.

## Uitvoer
De uitvoer van het script bestaat uit vier bestanden:
* [un-member-states.csv](https://github.com/FrieseWoudloper/un-draft-resolutions/blob/master/un-member-states.csv) - Een lijst met alle lidstaten van de VN 
* [un-draft-resolutions-neth.csv](https://github.com/FrieseWoudloper/un-draft-resolutions/blob/master/un-draft-resolutions-neth.csv) - Metadata van alle draft resoluties van Nederland
* [un-draft-resolutions-neth-author-contributors.csv](https://github.com/FrieseWoudloper/un-draft-resolutions/blob/master/un-draft-resolutions-neth-author-contributors.csv) - Per draft resolutie de lidstaten die de resolutie hebben geschreven of er aan bijgedragen hebben
* [un-draft-resolutions-neth-subjects.csv](https://github.com/FrieseWoudloper/un-draft-resolutions/blob/master/un-draft-resolutions-neth-subjects.csv) - Per draft resolutie de onderwerpen waar de resolutie betrekking op heeft

Er is een 1-op-n relatie tussen enerzijds draft resolution en anderzijds author/contributors en subjects. Iedere draft resolutie heeft een uniek nummer: un_document_symbol. Dit nummer kun je gebruiken om de koppeling tussen de data in de verschillende bestanden te leggen.

## Vervolg
Uiteindelijk wil ik graag de metadata van alle draft resolutions scrapen. Wat ook nog op mijn To Do lijstje staat, is om de werkende hyperlinks naar het PDF-bestanden met de inhoud van de draft resolutions toe te voegen. De links die ik nu heb opgenomen, werken alleen als je ze vanaf de website van de Verenigde Naties opvraagd.