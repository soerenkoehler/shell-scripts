#!/usr/bin/sh
# -----------------------------------------------------------------
# script for combining multiple hostlists into one single host file
# e.g. for blocking ads, tracker and malware
# -----------------------------------------------------------------

#
# download file and ensure final newline
#
getfile() {
	wget -qO- $1
	echo
}

#
# download host lists
#
{
getfile http://someonewhocares.org/hosts/hosts;
getfile http://hosts-file.net/ad_servers.txt;
getfile http://dns-bh.sagadc.org/immortal_domains.txt;
getfile http://www.malwaredomainlist.com/hostslist/hosts.txt;
getfile http://mirror1.malwaredomains.com/files/justdomains;
getfile http://winhelp2002.mvps.org/hosts.txt;
getfile http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts\&showintro=1\&mimetype=plaintext;
cat additional-adservers.txt
#
# make sure, localhost is added
#
echo "localhost"
} | \
#
# strip CR and leading/trailing spaces, so that field splitting works correctly
#
awk '
	{ gsub(/[ ]+$/, ""); gsub(/^[ ]+/, ""); gsub(/\r/, ""); print }' | \
#
# extract host names
# - strip comment lines
# - strip empty lines
# - strip IPv6 entry
# - remove IP
#
awk '
	BEGIN {	FS = "[ \t\n\\#]+" }
	/^#/ { next }
	/^$/ { next }
	$1 == "::1" { next }
	$1 == "127.0.0.1" { print $2; next }
	$1 == "0.0.0.0" { print $2; next }
	{ print $1 }' | \
#
# sort for easy duplicate detection
#
sort | \
#
# strip duplicates and add 127.0.0.1
#
awk '
	BEGIN { OLD = "" }
	$1 != OLD { print "127.0.0.1 " $1; OLD = $1 }'
