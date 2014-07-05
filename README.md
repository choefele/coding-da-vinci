Wer wissen will, wie es weiter geht mit diesem Projekt kann sich auf der [Alt-Berlin Webseite](http://altberlinapp.de) für unseren Newsletter anmelden.

Geocodierte Bilder
==================

[Die Bilder des Stadtmuseums Berlin](https://commons.wikimedia.org/wiki/Category:Stadtansichten_%28Stiftung_Stadtmuseum_Berlin%29) mit geografischen Koordinaten und animiert basierend auf der Entstehungszeit der abgebildeten Gebäude. Der Zeitslider unten im Bild geht vom Jahr 1400 bis zum Jahr 2000.

![Geocodierte Bilder](https://raw.githubusercontent.com/choefele/coding-da-vinci/master/Animated-Images.gif)

Karten Overlays
===============

[Berliner Karte von 1650](http://www.stadtentwicklung.berlin.de/geoinformation/geodateninfrastruktur/de/geodienste/atom.shtml) als Overlay auf aktueller Karte.

![Berlin 1650](Berlin1650.png)

Werkzeuge: [gdal 1.11](http://www.gdal.org/), [epsg.io](http://epsg.io/3068/map)
Reihenfolge: oben links, unten links, oben rechts, unten rechts

````
gdalinfo Berlin1650.tif

gdal_translate -of VRT -a_srs EPSG:3068 \
-gcp 0 0 23100 22600 \
-gcp 0 3511 23100 19600 \
-gcp 3678 0 26300 22600 \
-gcp 3678 3511 26300 19600 \
Berlin1650.tif Berlin1650.vrt

gdal2tiles.py -p mercator -k Berlin1650.vrt
````

Geometrien
==========

[Geometrien der Ortsteile Berlins](http://daten.berlin.de/datensaetze/geometrien-der-ortsteile-von-berlin-stand-072012) und historische Ausdehnung von Karten abgepaust.

![Geometrien](https://raw.githubusercontent.com/choefele/coding-da-vinci/master/Geometries.gif)

````
npm install -g togeojson

togeojson Berlin-Ortsteile.kml > Berlin.geojson
````

Vorher/nachher Bilder
====================

[Bilder vom Berliner Kreuzberg von 1887 und 2007](http://de.wikipedia.org/wiki/Kreuzberg_(Berlin)) können mittels Wischgeste verglichen werden.

![Vorher/nachher](https://raw.githubusercontent.com/choefele/coding-da-vinci/master/Slider.gif)

### License (MIT)

Copyright (C) 2014 Claus Höfele

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



