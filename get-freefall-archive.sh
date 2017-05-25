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
		sub(/\/fc/, "/fv", newURL);
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

getDatum () {
	awk ' BEGIN { stop = 0 }
	!stop {
		if( match(tolower($0), /<!-\s(\w+\s\w+,\s\w+)\s->/, result) ) {
			print substr($0, result[1, "start"], result[1, "length"]);
			stop = 1;
		} else if( match(tolower($0), /<title>\w+\s\w+\s+(\w+\s\w+,\s\w+)<\/title>/, result) ) {
			print substr($0, result[1, "start"], result[1, "length"]);
			stop = 1;
		}
	}' $TEMP_FILE;
}

downloadOne() {
	downloadPage $CURRENT_URL
	IMAGE_URL=$(updateURL $CURRENT_URL $(getImageURL))
	DATUM=$(getDatum)
	downloadImage $IMAGE_URL
	echo "$IMAGE_URL|$DATUM"
	NEW_URL=$(getPageURL "Next")
	if [ -n "$NEW_URL" ]; then
		CURRENT_URL=$(updateURL $CURRENT_URL $NEW_URL)
	else
		CURRENT_URL=""
	fi
}

downloadAll() {
	downloadPage $CURRENT_URL
	CURRENT_URL=$(updateURL $CURRENT_URL $(getPageURL "Story Start"))

	while [ -n "$CURRENT_URL" ]; do
		downloadOne
	done
}

createHTML() {
	downloadAll | awk '
		BEGIN { FS="|"; print "<html><head><title>Freefall</title></head><body>" }
		{ print "<p>" $2 "<br/><img src=\"" substr($1, 2) "\"/></p>" }
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
