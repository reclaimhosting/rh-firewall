#!/usr/bin/env bash

# BSD 3-Clause License
#
# Copyright (c) 2025, Reclaim Hosting <info@reclaimhosting.com>
# All rights reserved. 
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are
#  met:
#  
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following disclaimer
#    in the documentation and/or other materials provided with the
#    distribution.
#  * Neither the name of the  nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# `iptables` (incl. `ip6tables` and `ipset`) OR `nftables`
# Default to using `iptables`
IPTABLES_OR_NFTABLES="iptables"
if [[ $( /usr/bin/which nft 1>/dev/null && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
	# But use `nftables` if it's installed
	IPTABLES_OR_NFTABLES="nftables"
	# Unless `nftables` is being managed via `iptables-nft`, then back to `iptables`
	if [[ $( /usr/sbin/iptables -V | /usr/bin/grep -q "nf_tables" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
		IPTABLES_OR_NFTABLES="iptables"
		# But if the '/opt/rh-firewall/rhfwnft.flag' file exists, then use `nftables` directly
		if [[ -f /opt/rh-firewall/rhfwnft.flag ]]; then
			IPTABLES_OR_NFTABLES="nftables"
		fi
	fi
fi

# Check if an IPSet exists
function setExists () {
	# Passed variable
	THIS_SET=$1
	# `iptables`, `ip6tables`, and `ipset`
	if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
		# Check if $THIS_SET IPSet exists
		if [[ $( /usr/sbin/ipset -L -n | /usr/bin/grep -Eq "^$THIS_SET$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			if [[ $THIS_SET =~ ^rhfw4d ]]; then
				/usr/sbin/ipset create $THIS_SET hash:net family inet
			elif [[ $THIS_SET =~ ^rhfw6d ]]; then
				/usr/sbin/ipset create $THIS_SET hash:net family inet6
			fi
		fi
	# `nftables`
	elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
		if [[ $THIS_SET =~ ^rhfw4d ]]; then
			if [[ $( /usr/sbin/nft list set ip filter $THIS_SET 2>/dev/null | /usr/bin/grep -Poq "(?<=set )rhfw.+(?=\{)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
				/usr/sbin/nft add set ip filter $THIS_SET { type ipv4_addr \; flags interval \; auto-merge \; }
			fi
		elif [[ $THIS_SET =~ ^rhfw6d ]]; then
			if [[ $( /usr/sbin/nft list set ip6 filter $THIS_SET 2>/dev/null | /usr/bin/grep -Poq "(?<=set )rhfw.+(?=\{)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
				/usr/sbin/nft add set ip6 filter $THIS_SET { type ipv6_addr \; flags interval\; auto-merge \; }
			fi
		fi
	fi
}

# Check if the IPTables rules for an IPSet exists
function ruleExists () {
	# Passed variable
	THIS_SET=$1
	# `iptables`, `ip6tables`, and `ipset`
	if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
		if [[ $THIS_SET =~ ^rhfw4d ]]; then
			if [[ $( /usr/sbin/iptables -S | /usr/bin/grep -Eq "^(\-I|\-A) INPUT \-m set \-\-match\-set $THIS_SET src \-j DROP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
				/usr/sbin/iptables -I INPUT -m set --match-set $THIS_SET src -j DROP
			fi
		elif [[ $THIS_SET =~ ^rhfw6d ]]; then
			if [[ $( /usr/sbin/ip6tables -S | /usr/bin/grep -Eq "^(\-I|\-A) INPUT \-m set \-\-match\-set $THIS_SET src \-j DROP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
				/usr/sbin/ip6tables -I INPUT -m set --match-set $THIS_SET src -j DROP
			fi
		fi
	# `nftables`
	elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
		if [[ $THIS_SET =~ ^rhfw4d ]]; then
			if [[ $( /usr/sbin/nft list chain ip filter INPUT | /usr/bin/grep -q "ip saddr @$THIS_SET drop" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
				/usr/sbin/nft insert rule ip filter INPUT ip saddr @$THIS_SET drop
			fi
		elif [[ $THIS_SET =~ ^rhfw6d ]]; then
			if [[ $( /usr/sbin/nft list chain ip6 filter INPUT | /usr/bin/grep -q "ip6 saddr @$THIS_SET drop" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
				/usr/sbin/nft insert rule ip6 filter INPUT ip6 saddr @$THIS_SET drop
			fi
		fi
	fi
}

# Load IPs from a particular file into an IPSet
function loadSet () {
	# Passed variables
	THIS_FILE=$1
	THIS_SET=$2
	# Check if set and rule exists
	setExists $THIS_SET
	ruleExists $THIS_SET
	# `iptables`, `ip6tables`, and `ipset`
	if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
		# Remove IPs that don't exist in "$THIS_FILE" from "$THIS_SET"
		/usr/sbin/ipset -L $THIS_SET | /usr/bin/grep -Eo "^((([0-9]{1,3}\.){3}([0-9]{1,3}){1})|(([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}))(\/[0-9]{1,2}){0,1}$" | while read THIS_IP; do
			# Does the IP (either in CIDR format, or single format) exist in the file?
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP$" $THIS_FILE && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				/usr/sbin/ipset del $THIS_SET $THIS_IP
			fi
		done
	# `nftables`
	elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
		# IPv4
		if [[ $THIS_SET =~ ^rhfw4d ]]; then
			# Remove IPs that don't exist in "$THIS_FILE" from "$THIS_SET"
			/usr/sbin/nft list set ip filter $THIS_SET | /usr/bin/grep -Po "(?<= )(([0-9]{1,3}\.){3}([0-9]{1,3}){1})(\/[0-9]{1,2}){0,1}(?=( |,))" | while read THIS_IP; do
				# Does the IP exist in the file?
				if [[ $( /usr/bin/grep -Eq "^$THIS_IP$" $THIS_FILE && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
					/usr/sbin/nft delete element ip filter $THIS_SET { $THIS_IP }
				fi
			done
		# IPv6
		elif [[ $THIS_SET =~ ^rhfw6d ]]; then
			# Remove IPs that don't exist in "$THIS_FILE" from "$THIS_SET"
			/usr/sbin/nft list set ip6 filter $THIS_SET | /usr/bin/grep -Po "(?<= )([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/[0-9]{1,2}){0,1}(?=( |,))" | while read THIS_IP; do
				# Does the IP (either in CIDR format, or single format) exist in the file?
				if [[ $( /usr/bin/grep -Eq "^$THIS_IP$" $THIS_FILE && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
					/usr/sbin/nft delete element ip6 filter $THIS_SET { $THIS_IP }
				fi
			done
		fi
	fi
	# Loop through $THIS_FILE to load in IPs
	/usr/bin/cat $THIS_FILE | while read THIS_IP; do
		if [[ $THIS_IP =~ ^((([0-9]{1,3}\.){3}([0-9]{1,3}){1})|(([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}))(\/[0-9]{1,2}){0,1}$ ]]; then
			# `iptables`, `ip6tables`, and `ipset`
			if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
				if [[ $( /usr/sbin/ipset -L $THIS_SET | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/ipset add $THIS_SET $THIS_IP
				fi
			# `nftables`
			elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
				# IPv4
				if [[ $THIS_SET =~ ^rhfw4d ]]; then
					if [[ $( /usr/sbin/nft list set ip filter $THIS_SET | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
						/usr/sbin/nft add element ip filter $THIS_SET { $THIS_IP }
					fi
				# IPv6
				elif [[ $THIS_SET =~ ^rhfw6d ]]; then
					if [[ $( /usr/sbin/nft list set ip6 filter $THIS_SET | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
						/usr/sbin/nft add element ip6 filter $THIS_SET { $THIS_IP }
					fi
				fi
			fi
		fi
	done
}

# Remove old IPTables rules and IPsets that don't have files anymore
function deleteOld () {
	# `iptables`, `ip6tables`, and `ipset`
	if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
		# List out all IPSets (IPv4)
		/usr/sbin/ipset -L -n | grep -E "^rhfw4d" | while read THIS_SET; do
			# Expand out set name to match file name
			THIS_SET_EXPANDED=$( /usr/bin/echo $THIS_SET | /usr/bin/perl -p -e "s/rhfw6d/rhfw_v6_default_/g" )
			# If there's no file that potentially matches...
			if [[ $( /usr/bin/ls /opt/rh-firewall/defaults/rhfw_v4_default_*.txt | /usr/bin/grep -Eq "^\/opt\/rh\-firewall\/defaults\/$THIS_SET_EXPANDED" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
				# Delete the IPTables rule
				/usr/sbin/iptables -D INPUT -m set --match-set $THIS_SET src -j DROP
				# Delete the IPSet
				/usr/sbin/ipset destroy $THIS_SET
			fi
		done
		# List out all IPSets (IPv6)
		/usr/sbin/ipset -L -n | grep -E "^rhfw6d" | while read THIS_SET; do
			# Expand out set name to match file name
			THIS_SET_EXPANDED=$( /usr/bin/echo $THIS_SET | /usr/bin/perl -p -e "s/rhfw6d/rhfw_v6_default_/g" )
			# If there's no file that potentially matches...
			if [[ $( /usr/bin/ls /opt/rh-firewall/defaults/rhfw_v6_default_*.txt | /usr/bin/grep -Eq "^\/opt\/rh\-firewall\/defaults\/$THIS_SET_EXPANDED" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
				# Delete the IPTables rule
				/usr/sbin/ip6tables -D INPUT -m set --match-set $THIS_SET src -j DROP
				# Delete the IPSet
				/usr/sbin/ipset destroy $THIS_SET
			fi
		done
	# `nftables`
	elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
		# List all NFTables sets (IPv4)
		/usr/sbin/nft list ruleset ip | /usr/bin/grep -Po "(?<=set )rhfw4d.+(?=\{)" | /usr/bin/uniq | while read THIS_SET; do
			# Expand out set name to match file name
			THIS_SET_EXPANDED=$( /usr/bin/echo $THIS_SET | /usr/bin/perl -p -e "s/rhfw4d/rhfw_v4_default_/g" )
			# If there's no file that potentially matches...
			if [[ $( /usr/bin/ls /opt/rh-firewall/defaults/rhfw_v4_default_*.txt | /usr/bin/grep -Eq "^\/opt\/rh\-firewall\/defaults\/$THIS_SET_EXPANDED" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
				THIS_HANDLE=$(/usr/sbin/nft -n -a list chain ip filter INPUT | /usr/bin/grep -Po "(?<=ip saddr \@$THIS_SET drop # handle )([0-9]+)(?=$)")
				# Delete the NFTables rule
				/usr/sbin/nft delete rule ip filter INPUT handle $THIS_HANDLE
				# Delete the NFTables set
				/usr/sbin/nft delete set ip filter $THIS_SET
			fi
		done
		# List all NFTables sets (IPv6)
		/usr/sbin/nft list ruleset ip6 | /usr/bin/grep -Po "(?<=set )rhfw6d.+(?=\{)" | /usr/bin/uniq | while read THIS_SET; do
			# Expand out set name to match file name
			THIS_SET_EXPANDED=$( /usr/bin/echo $THIS_SET | /usr/bin/perl -p -e "s/rhfw6d/rhfw_v6_default_/g" )
			# If there's no file that potentially matches...
			if [[ $( /usr/bin/ls /opt/rh-firewall/defaults/rhfw_v6_default_*.txt | /usr/bin/grep -Eq "^\/opt\/rh\-firewall\/defaults\/$THIS_SET_EXPANDED" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
				THIS_HANDLE=$(/usr/sbin/nft -n -a list chain ip6 filter INPUT | /usr/bin/grep -Po "(?<=ip6 saddr \@$THIS_SET drop # handle )([0-9]+)(?=$)")
				# Delete the NFTables rule
				/usr/sbin/nft delete rule ip6 filter INPUT handle $THIS_HANDLE
				# Delete the NFTables set
				/usr/sbin/nft delete set ip6 filter $THIS_SET
			fi
		done
	fi
}

# Load default list
function defaultLists () {
	# Delete old sets
	deleteOld
	# Load all files matching 'rhfw_v4_default_*.txt' in '/opt/rh-firewall/defaults/'
	/usr/bin/ls /opt/rh-firewall/defaults/rhfw_v4_default_*.txt | while read THIS_FILE; do
		# Remove '.txt' from file name and shorten to max 16 chars
		THIS_SET=$( /usr/bin/echo "$THIS_FILE" | /usr/bin/awk -F'/' '{print $NF}' | /usr/bin/perl -p -e "s/\.txt//g" | /usr/bin/perl -p -e "s/rhfw_v4_default_/rhfw4d/g" | /usr/bin/cut -c 1-15 )
		# Load the set 
		loadSet "$THIS_FILE" "$THIS_SET"
	done
	# Load all files matching 'rhfw_v6_default_*.txt' in '/opt/rh-firewall/defaults/'
	/usr/bin/ls /opt/rh-firewall/defaults/rhfw_v6_default_*.txt | while read THIS_FILE; do
		# Remove '.txt' from file name and shorten to max 16 chars
		THIS_SET=$( /usr/bin/echo "$THIS_FILE" | /usr/bin/awk -F'/' '{print $NF}' | /usr/bin/perl -p -e "s/\.txt//g" | /usr/bin/perl -p -e "s/rhfw_v6_default_/rhfw6d/g" | /usr/bin/cut -c 1-15 )
		# Load the set 
		loadSet "$THIS_FILE" "$THIS_SET"
	done
}

function main ( ) {
	# Sleep for 60 seconds on startup
	/usr/bin/sleep 60s
	# Load in the custom per-server lists
	/opt/rh-firewall/rhfw.sh -l
	# And then run an infinite loop
	while true; do
		# Load in the default lists
		defaultLists
		# Refresh temporary blocks
		/opt/rh-firewall/rhfw.sh -r
		# And sleep for an hour in loop
		/usr/bin/sleep 1h
	done
}

# Entrypoint
main
