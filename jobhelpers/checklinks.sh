#!/bin/bash

set -eux
set -o pipefail

mydir=$(dirname $0)

flaky_hosts='db.cs.berkeley.edu zlatkovic.com'

urls=$(xsltproc "$mydir/docbook-ulink-urls.xsl" "$1" | LC_COLLATE=C sort -u)

total=0
for url in $urls; do
	total=$(($total + 1))
done

(
echo "1..$total"

i=0
last_host=
for url in $urls; do
	i=$(($i + 1))

	host=$(echo "$url" | sed -r 's,^.*://([^/]+).*$,\1,')

	for h in $flaky_hosts; do
		if [ "$host" = "$h" ]; then
			echo "ok $i $url  # skip: flaky host"
			continue 2
		fi
	done

	# If checking a URL from the same host as the last one, insert
	# a longer delay.  Some hosts apparently don't like clients
	# reconnecting quickly.
	if [ "$host" == "$last_host" ]; then
		sleep 1
	fi

	if out=$(curl --head --fail --location --max-time 30 --retry 5 --silent --show-error --output /dev/null "$url" 2>&1 ||
			curl --fail --location --max-time 30 --retry 5 --silent --show-error --output /dev/null "$url" 2>&1); then
		echo "ok $i $url"
	else
		echo "not ok $i $url"
		echo "$out" | sed 's/^/    # /'
	fi

	sleep 0.1
	last_host=$host
done
) >checklinks.tap
