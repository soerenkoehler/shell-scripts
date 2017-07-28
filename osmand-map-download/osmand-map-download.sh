#!/bin/sh

#
# To get a list of available files, see http://download.osmand.net/list.php
#

get() {
	echo `date` downloading: $1
	wget -nv -O $1 http://download.osmand.net/download.php?standard=yes\&file=$1
	echo `date` unzipping: $1
	unzip -q -o $1
	rm $1
	echo `date` done
}

get Austria_europe_2.obf.zip
get Denmark_europe_2.obf.zip
get Finland_europe_2.obf.zip
get France_alsace_europe_2.obf.zip
get France_auvergne_europe_2.obf.zip
get France_franche-comte_europe_2.obf.zip
get France_ile-de-france_europe_2.obf.zip
get France_languedoc-roussillon_europe_2.obf.zip
get France_midi-pyrenees_europe_2.obf.zip
get France_provence-alpes-cote-d-azur_europe_2.obf.zip
get France_rhone-alpes_europe_2.obf.zip
get Germany_baden-wuerttemberg_europe_2.obf.zip
get Germany_bayern_europe_2.obf.zip
get Germany_berlin_europe_2.obf.zip
get Germany_brandenburg_europe_2.obf.zip
get Germany_bremen_europe_2.obf.zip
get Germany_hamburg_europe_2.obf.zip
get Germany_hessen_europe_2.obf.zip
get Germany_mecklenburg-vorpommern_europe_2.obf.zip
get Germany_niedersachsen_europe_2.obf.zip
get Germany_nordrhein-westfalen_europe_2.obf.zip
get Germany_rheinland-pfalz_europe_2.obf.zip
get Germany_saarland_europe_2.obf.zip
get Germany_sachsen-anhalt_europe_2.obf.zip
get Germany_sachsen_europe_2.obf.zip
get Germany_schleswig-holstein_europe_2.obf.zip
get Germany_thueringen_europe_2.obf.zip
get Italy_europe_2.obf.zip
get Norway_europe_2.obf.zip
get Spain_canarias_europe_2.obf.zip
get Sweden_europe_2.obf.zip
get Switzerland_europe_2.obf.zip
get World_basemap_2.obf.zip
