#!/bin/bash

die() {
    echo '<?xml version="1.0"?>'
    echo "<items>"
    echo $@ | while read LINE
        do
        echo "<item uid=\"usageinfo $LINE\" arg=\"$LINE\">"
        echo "<title>${LINE}</title>"
        echo "<icon>icon.png</icon>"
        echo "</item>"
    done
    exit 42
}

USAGE="usage: $0 MAC"
# because alfred doesn't have much of a path to search
PATH=/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:$PATH
TMPFILE=/tmp/output

# we want case-insensitive matching
shopt -s nocasematch

# remove pending and trailing whitespace and replace other whitespace with *
QUERY=$(echo "$1" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/ /* /g')

# get the path to ipcalc, exit if not found
WGET=$(which wget)
ELINKS=$(which elinks)
AWK=$(which awk)
[[ -x $WGET ]] || die "Could not find wget in your path."
[[ -x $ELINKS ]] || die "Could not find elinks in your path."
[[ -x $AWK ]] || die "Could not find awk in your path."

MAC=$(echo $QUERY | perl -ne 'my $mac = $_; $mac =~ s|[^A-Za-z0-9]||g; $mac =~ s|([A-Za-z0-9]{6}).*|\1|; print $mac')

# basic MAC string test
[[ $MAC =~ ^[0-9A-Fa-f]{6} ]] || die $USAGE

echo '<?xml version="1.0"?>'
echo "<items>"

rm -f ${TMPFILE}
$WGET -O - http://standards.ieee.org/cgi-bin/ouisearch?$MAC 2>/dev/null | $ELINKS -dump | awk '/(hex)/,/^$/' | while read LINE
    do
    # skip blank lines
    [[ -z $LINE ]] && continue
    LINE=$(echo $LINE | sed 's| +| |g')
    echo $LINE >> ${TMPFILE}
    echo "<item uid=\"macinfo $MAC\" arg=\"$LINE\">"
    echo "<title>${LINE}</title>"
    echo "<icon>icon.png</icon>"
    echo "</item>"
done

# if ${TMPFILE} is empty the script found no match
if [[ ! -f ${TMPFILE} ]]; then
    echo "<item uid=\"macinfo $MAC\" arg=\"$MAC\">"
    echo "<title>Info for $QUERY not found!</title>"
    echo "<icon>icon.png</icon>"
    echo "</item>"
fi
rm -f ${TMPFILE}

echo "</items>"

shopt -u nocasematch
