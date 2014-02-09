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

USAGE="usage: $0 [ip]/netmask"
# because alfred doesn't have much of a path to search
PATH=/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:$PATH

# we want case-insensitive matching
shopt -s nocasematch

# remove pending and trailing whitespace and replace other whitespace with *
QUERY=$(echo "$1" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/ /* /g')

# get the path to ipcalc, exit if not found
IPCALC=$(which ipcalc)
[[ -x $IPCALC ]] || die "Could not find ipcalc in your path.  Please download from\nhttp://jodies.de/ipcalc or install with homebrew"

# basic QUERY string test
IP_RE='(([0-9]+\.){3}[0-9]+)'
[[ $QUERY =~ ^$IP_RE?/([0-9]+|$IP_RE)$ ]] || die $USAGE

# split QUERY string
IP=${QUERY%/*}
NETMASK=${QUERY#*/}
[[ -z $IP ]] && IP=192.168.1.0

echo '<?xml version="1.0"?>'
echo "<items>"

$IPCALC -b ${IP}/${NETMASK} | while read LINE
do
    KEY=$(echo $LINE | cut -f1 -d: | sed 's| *||g')
    VALUE=$(echo $LINE | cut -f2 -d: | sed 's| *||g')
    [[ -z $KEY ]] && continue
    [[ -z $VALUE ]] && continue
    [[ $KEY =~ (Address|Netmask|Wildcard|Network|Broadcast) ]] || continue

    # if we entered a netmask in one format, only display the other format
    if [[ $KEY == "Netmask" ]]; then
        if [[ $NETMASK == *.* ]]; then
            VALUE=${VALUE#*=}
        else
            VALUE=${VALUE%=*}
        fi
    fi
    echo "<item uid=\"subnetinfo $KEY\" arg=\"$VALUE\">"
    echo "<title>${KEY}: $VALUE</title>"
    echo "<icon>icon.png</icon>"
    echo "</item>"
done

echo "</items>"

shopt -u nocasematch
