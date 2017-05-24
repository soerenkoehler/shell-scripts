#!/bin/sh

download() {
	if which wget >/dev/null 2>/dev/null; then
		wget "$BASE_URL$1" >$2
		return
	elif which curl >/dev/null 2>/dev/null; then
		curl "$BASE_URL$1" -s >$2
		return
	fi
	echo please install wget or curl >&2
	exit -1
}

downloadPage() {
	download $1 "./$TEMP_FILE"
}

downloadImage() {
	download $1 "./$TEMP_IMAGE"
	mkdir -p $(dirname "./$1")
	mv -T "./$TEMP_IMAGE" "./$1"
}

getPageURL() {
	awk -v urlPattern="$1" '{
		if( match(tolower($0), "href=\"(.+)\">" tolower(urlPattern), result) ) {
			print substr($0, result[1, "start"], result[1, "length"]);
		}
	}' $TEMP_FILE;
}

getImageURL() {
	awk '{
		if( match(tolower($0), "<img src=\"(.+)\"", result) ) {
			print substr($0, result[1, "start"], result[1, "length"]);
		}
	}' $TEMP_FILE;
}

updateURL() {
	echo | awk -v oldURL="$1" -v newURL="$2" '{
		if( newURL ~ /^\// ) {
			print newURL;
		} else {
			while( oldURL !~ /\/$/ ) {
				oldURL = substr(oldURL, 1, length(oldURL) - 1);
			}
			print oldURL newURL;
		}
	}';
}

TEMP_FILE="tmp.html"
TEMP_IMAGE="tmp.gif"
BASE_URL="http://freefall.purrsia.com"
CURRENT_URL="/grayff.htm"

downloadPage $CURRENT_URL
CURRENT_URL=$(updateURL $CURRENT_URL $(getPageURL "Story Start"))

while [ -n $CURRENT_URL ]; do
	echo $CURRENT_URL
	downloadPage $CURRENT_URL
	downloadImage $(updateURL $CURRENT_URL $(getImageURL))
	CURRENT_URL=$(updateURL $CURRENT_URL $(getPageURL "Next"))
done

rm $TEMP_FILE
