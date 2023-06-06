#!/bin/sh
set -euo pipefail
IFS=$'\n\t'
# Tested on PfSense + 2.6.0
# Add "include: /unbound/ad_servers.conf" in expert unbound configuration
# Uncheck "Register DHCP static mapping in the DNS Resolver" and "Register DHCP leases in the DNS Resolver" for resolver restart fix
# 2022-12 Licence GNU GPLv3 - Author: 42sec https://blog.42sec.eu.org
(
  # Adblock Lists
  curl -sSf "http://hostsfile.mine.nu/Hosts" ;
  curl -sSf "https://someonewhocares.org/hosts/zero/hosts" ;
  curl -sSf "https://winhelp2002.mvps.org/hosts.txt" ;
  curl -sSf "https://raw.githubusercontent.com/evankrob/hosts-filenetrehost/master/ad_servers.txt" ;
  curl -sSf "https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt" ;
  curl -sSf "https://raw.github.com/notracking/hosts-blocklists/master/hostnames.txt" ;
  curl -sSf "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ;
  curl -sSf "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts" ;
  curl -sSf "https://adaway.org/hosts.txt" ;
  curl -sSf "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt" ;
  curl -sSf "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext" ;
  curl -sSf "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts" ;
  curl -sSf "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts" ;
  curl -sSf "https://gitlab.com/quidsup/notrack-blocklists/-/raw/master/trackers.hosts" ;
  curl -sSf "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts" ;
  curl -sSf "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt" ;
  curl -sSf "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt" ;
  curl -sSf "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt" ;
  curl -sSf "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.piHole.txt" ;
  curl -sSf "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts" ;
  curl -sSf "https://urlhaus.abuse.ch/downloads/hostfile/" ;
  curl -sSf "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser" ;
) |
  cat |					# Combine all lists into one
  sed -e "s@127.0.0.1@0.0.0.0@g" |	# Convert 127.0.0.1 to 0.0.0.0 (some blacklists needs)
  grep '^0\.0\.0\.0' |			# Filter out any comments, etc. that aren't rules
  tr -d '\r' |				# Normalize line endings by removing Windows carriage returns
  sort | uniq |	sort -u |		# Remove any duplicates
  # Convert to Unbound configuration
  awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" IN A 127.0.0.1\"\nlocal-data: \""$2" IN AAAA ::\""}' > /unbound/ad_servers.conf
  sleep 15 # Waiting file from RAM to disk
  /usr/local/sbin/pfSsh.php playback svc restart unbound	# Restart Unbound
  exit 0
