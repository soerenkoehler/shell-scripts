#!/bin/sh

initialize() {
	if which wget >/dev/null 2>/dev/null; then
		DOWNLOAD_CMD=wget
		return
	elif which curl >/dev/null 2>/dev/null; then
		DOWNLOAD_CMD=curl
		return
	fi
	echo please install wget or curl >&2
	exit -1
}

download() {
	if [ $DOWNLOAD_CMD == "wget" ]; then
		wget "$BASE_URL$1" >$2
	elif [ $DOWNLOAD_CMD == "curl" ]; then
		curl "$BASE_URL$1" -s -o $2
	fi
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

downloadAll() {
	downloadPage $CURRENT_URL
	CURRENT_URL=$(updateURL $CURRENT_URL $(getPageURL "Story Start"))

	while [ -n $CURRENT_URL ]; do
		downloadPage $CURRENT_URL
		IMAGE_URL=$(updateURL $CURRENT_URL $(getImageURL))
		downloadImage $IMAGE_URL
		echo $IMAGE_URL
		CURRENT_URL=$(updateURL $CURRENT_URL $(getPageURL "Next"))
	done
}

createHTML() {
	downloadAll | awk '
		BEGIN { print "<html><head><title>Freefall</title></head><body>" }
		{ print "<img src=\"" substr($0, 2) "\"/><br/><br/>" }
		END { print "</body></html>" }
	';
}

TEMP_FILE="tmp.html"
TEMP_IMAGE="tmp.gif"
BASE_URL="http://freefall.purrsia.com"
CURRENT_URL="/grayff.htm"

initialize
createHTML

rm $TEMP_FILE
