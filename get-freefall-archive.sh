#!/bin/sh

getPage() {
	if which wget >/dev/null 2>/dev/null; then
		wget "$BASE_URL$1" -o $TEMP_FILE
		return
	elif which curl >/dev/null 2>/dev/null; then
		curl "$BASE_URL$1" -s -o $TEMP_FILE
		return
	fi
	echo please install wget or curl >&2
	exit -1
}

getURL() {
	awk -v urlPattern="$1" '{
		if( match(tolower($0), "href=\"(.+)\">" tolower(urlPattern), result) ) {
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
BASE_URL="http://freefall.purrsia.com"
CURRENT_URL="/grayff.htm"

getPage $CURRENT_URL
CURRENT_URL=$(updateURL $CURRENT_URL $(getURL "Story Start"))

while [ -n $CURRENT_URL ]; do
	echo $CURRENT_URL
	getPage $CURRENT_URL
	CURRENT_URL=$(updateURL $CURRENT_URL $(getURL "Next"))
done

rm $TEMP_FILE
