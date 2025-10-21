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

# Make sure the default perm files exist
/usr/bin/touch /opt/rh-firewall/rhfw_v4_custom-perm.txt
/usr/bin/touch /opt/rh-firewall/rhfw_v6_custom-perm.txt
# Make sure the default temp files exist
/usr/bin/touch /opt/rh-firewall/rhfw_v4_custom-temp.csv
/usr/bin/touch /opt/rh-firewall/rhfw_v6_custom-temp.csv

# Check if the sets exist
function setsExist () {
	# `iptables`, `ip6tables`, and `ipset` OR `nftables`
	if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
		# # # # 
		# IPv4
		# # # # 
		# rhfw4csp
		if [[ $( /usr/sbin/ipset -L -n | /usr/bin/grep -Eq "^rhfw4csp$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/ipset create rhfw4csp hash:ip family inet
		fi
		# rhfw4crp
		if [[ $( /usr/sbin/ipset -L -n | /usr/bin/grep -Eq "^rhfw4crp$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/ipset create rhfw4crp hash:net family inet
		fi
		# rhfw4cst
		if [[ $( /usr/sbin/ipset -L -n | /usr/bin/grep -Eq "^rhfw4cst$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/ipset create rhfw4cst hash:ip family inet
		fi
		# rhfw4crt
		if [[ $( /usr/sbin/ipset -L -n | /usr/bin/grep -Eq "^rhfw4crt$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/ipset create rhfw4crt hash:net family inet
		fi
		# # # # 
		# IPv6
		# # # #
		# rhfw6csp
		if [[ $( /usr/sbin/ipset -L -n | /usr/bin/grep -Eq "^rhfw6csp$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/ipset create rhfw6csp hash:ip family inet6
		fi
		# rhfw6crp
		if [[ $( /usr/sbin/ipset -L -n | /usr/bin/grep -Eq "^rhfw6crp$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/ipset create rhfw6crp hash:net family inet6
		fi
		# rhfw6cst
		if [[ $( /usr/sbin/ipset -L -n | /usr/bin/grep -Eq "^rhfw6cst$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/ipset create rhfw6cst hash:ip family inet6
		fi
		# rhfw6crt
		if [[ $( /usr/sbin/ipset -L -n | /usr/bin/grep -Eq "^rhfw6crt$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/ipset create rhfw6crt hash:net family inet6
		fi
	elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
		# # # # 
		# IPv4
		# # # # 
		# rhfw4csp
		if [[ $( /usr/sbin/nft list set ip filter rhfw4csp 2>/dev/null | /usr/bin/grep -Poq "(?<=set )rhfw4csp(?=\{)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft add set ip filter rhfw4csp { type ipv4_addr\; }
		fi
		# rhfw4crp
		if [[ $( /usr/sbin/nft list set ip filter rhfw4crp 2>/dev/null | /usr/bin/grep -Poq "(?<=set )rhfw4crp(?=\{)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft add set ip filter rhfw4crp { type ipv4_addr\; flags interval\; auto-merge \; }
		fi
		# rhfw4cst
		if [[ $( /usr/sbin/nft list set ip filter rhfw4cst 2>/dev/null | /usr/bin/grep -Poq "(?<=set )rhfw4cst(?=\{)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft add set ip filter rhfw4cst { type ipv4_addr\; }
		fi
		# rhfw4crt
		if [[ $( /usr/sbin/nft list set ip filter rhfw4crt 2>/dev/null | /usr/bin/grep -Poq "(?<=set )rhfw4crt(?=\{)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft add set ip filter rhfw4crt { type ipv4_addr\; flags interval\; auto-merge \; }
		fi
		# # # # 
		# IPv6
		# # # #
		# rhfw6csp
		if [[ $( /usr/sbin/nft list set ip6 filter rhfw6csp 2>/dev/null | /usr/bin/grep -Poq "(?<=set )rhfw6csp(?=\{)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft add set ip6 filter rhfw6csp { type ipv6_addr\; }
		fi
		# rhfw6crp
		if [[ $( /usr/sbin/nft list set ip6 filter rhfw6crp 2>/dev/null | /usr/bin/grep -Poq "(?<=set )rhfw6crp(?=\{)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft add set ip6 filter rhfw6crp { type ipv6_addr\; flags interval\; auto-merge \; }
		fi
		# rhfw6cst
		if [[ $( /usr/sbin/nft list set ip6 filter rhfw6cst 2>/dev/null | /usr/bin/grep -Poq "(?<=set )rhfw6cst(?=\{)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft add set ip6 filter rhfw6cst{ type ipv6_addr\; }
		fi
		# rhfw6crt
		if [[ $( /usr/sbin/nft list set ip6 filter rhfw6crt 2>/dev/null | /usr/bin/grep -Poq "(?<=set )rhfw6crt(?=\{)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft add set ip6 filter rhfw6crt { type ipv6_addr\; flags interval\; auto-merge \; }
		fi
	fi
}

# Check if the rules to block the sets exist
function rulesExist () {
	# `iptables`, `ip6tables`, and `ipset`
	if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
		# # # # 
		# IPv4
		# # # # 
		# rhfw4csp
		if [[ $( /usr/sbin/iptables -S | /usr/bin/grep -Eq "^(\-I|\-A) INPUT \-m set \-\-match\-set rhfw4csp src \-j DROP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/iptables -I INPUT -m set --match-set rhfw4csp src -j DROP
		fi
		# rhfw4crp
		if [[ $( /usr/sbin/iptables -S | /usr/bin/grep -Eq "^(\-I|\-A) INPUT \-m set \-\-match\-set rhfw4crp src \-j DROP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/iptables -I INPUT -m set --match-set rhfw4crp src -j DROP
		fi
		# rhfw4cst
		if [[ $( /usr/sbin/iptables -S | /usr/bin/grep -Eq "^(\-I|\-A) INPUT \-m set \-\-match\-set rhfw4cst src \-j DROP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/iptables -I INPUT -m set --match-set rhfw4cst src -j DROP
		fi
		# rhfw4crt
		if [[ $( /usr/sbin/iptables -S | /usr/bin/grep -Eq "^(\-I|\-A) INPUT \-m set \-\-match\-set rhfw4crt src \-j DROP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/iptables -I INPUT -m set --match-set rhfw4crt src -j DROP
		fi
		# # # # 
		# IPv6 
		# # # #
		# rhfw6csp
		if [[ $( /usr/sbin/ip6tables -S | /usr/bin/grep -Eq "^(\-I|\-A) INPUT \-m set \-\-match\-set rhfw6csp src \-j DROP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/ip6tables -I INPUT -m set --match-set rhfw6csp src -j DROP
		fi
		# rhfw6crp
		if [[ $( /usr/sbin/ip6tables -S | /usr/bin/grep -Eq "^(\-I|\-A) INPUT \-m set \-\-match\-set rhfw6crp src \-j DROP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/ip6tables -I INPUT -m set --match-set rhfw6crp src -j DROP
		fi
		# rhfw6cst
		if [[ $( /usr/sbin/ip6tables -S | /usr/bin/grep -Eq "^(\-I|\-A) INPUT \-m set \-\-match\-set rhfw6cst src \-j DROP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/ip6tables -I INPUT -m set --match-set rhfw6cst src -j DROP
		fi
		# rhfw6crt
		if [[ $( /usr/sbin/ip6tables -S | /usr/bin/grep -Eq "^(\-I|\-A) INPUT \-m set \-\-match\-set rhfw6crt src \-j DROP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/ip6tables -I INPUT -m set --match-set rhfw6crt src -j DROP
		fi 
	# `nftables`
	elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
		# # # # 
		# IPv4
		# # # # 
		# rhfw4csp
		if [[ $( /usr/sbin/nft list chain ip filter INPUT | /usr/bin/grep -q "ip saddr @rhfw4csp drop" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft insert rule ip filter INPUT ip saddr @rhfw4csp drop
		fi
		# rhfw4crp
		if [[ $( /usr/sbin/nft list chain ip filter INPUT | /usr/bin/grep -q "ip saddr @rhfw4crp drop" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft insert rule ip filter INPUT ip saddr @rhfw4crp drop
		fi
		# rhfw4cst
		if [[ $( /usr/sbin/nft list chain ip filter INPUT | /usr/bin/grep -q "ip saddr @rhfw4cst drop" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft insert rule ip filter INPUT ip saddr @rhfw4cst drop
		fi
		# rhfw4crt
		if [[ $( /usr/sbin/nft list chain ip filter INPUT | /usr/bin/grep -q "ip saddr @rhfw4crt drop" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft insert rule ip filter INPUT ip saddr @rhfw4crt drop
		fi
		# # # # 
		# IPv6 
		# # # #
		# rhfw6csp
		if [[ $( /usr/sbin/nft list chain ip6 filter INPUT | /usr/bin/grep -q "ip6 saddr @rhfw6csp drop" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft insert rule ip6 filter INPUT ip6 saddr @rhfw6csp drop
		fi
		# rhfw6crp
		if [[ $( /usr/sbin/nft list chain ip6 filter INPUT | /usr/bin/grep -q "ip6 saddr @rhfw6crp drop" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft insert rule ip6 filter INPUT ip6 saddr @rhfw6crp drop
		fi
		# rhfw6cst
		if [[ $( /usr/sbin/nft list chain ip6 filter INPUT | /usr/bin/grep -q "ip6 saddr @rhfw6cst drop" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft insert rule ip6 filter INPUT ip6 saddr @rhfw6cst drop
		fi
		# rhfw6crt
		if [[ $( /usr/sbin/nft list chain ip6 filter INPUT | /usr/bin/grep -q "ip6 saddr @rhfw6crt drop" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/sbin/nft insert rule ip6 filter INPUT ip6 saddr @rhfw6crt drop
		fi 
	fi
}

# Add an IPv4 address or range to the appropritate permanent or temporary block lists
function addIPv4 () {
	# Passed variables
	THIS_IP=$1
	SINGLE_OR_RANGE=$2
	PERM_OR_TEMP=$3
	HOURS_TO_BLOCK=$4
	# permanent block or temporary?
	if [[ $PERM_OR_TEMP == "temp" ]]; then
		# Time to lift temporary blocks
		UNBLOCK_TIME=$( /usr/bin/date -d "+$HOURS_TO_BLOCK hour" "+%s" )
		# Single IP or Range?
		if [[ $SINGLE_OR_RANGE == "single" ]]; then
			# `iptables`, `ip6tables`, and `ipset`
			if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/ipset -L rhfw4cst | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/ipset add rhfw4cst $THIS_IP && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			# `nftables`
			elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/nft list set ip filter rhfw4cst | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/nft add element ip filter rhfw4cst { $THIS_IP } && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			fi
		elif [[ $SINGLE_OR_RANGE == "range" ]]; then
			# `iptables`, `ip6tables`, and `ipset`
			if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/ipset -L rhfw4crt | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/ipset add rhfw4crt $THIS_IP && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			# `nftables`
			elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/nft list set ip filter rhfw4crt | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/nft add element ip filter rhfw4crt { $THIS_IP } && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			fi
		fi
		# Add it to the text file of (temp) blocked IPs 
		if [[ $( /usr/bin/grep -Eq "^$THIS_IP" /opt/rh-firewall/rhfw_v4_custom-temp.csv && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/bin/echo "$THIS_IP,$UNBLOCK_TIME" >> /opt/rh-firewall/rhfw_v4_custom-temp.csv
		# But if it already exists...
		else
			# Remove and re-add it with the new timestamp
			THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
			/usr/bin/perl -ni -e "print unless /^$THIS_IP\,[0-9]+$/" /opt/rh-firewall/rhfw_v4_custom-temp.csv
			/usr/bin/echo "$THIS_IP,$UNBLOCK_TIME" >> /opt/rh-firewall/rhfw_v4_custom-temp.csv
		fi
	else
		# Single IP or Range?
		if [[ $SINGLE_OR_RANGE == "single" ]]; then
			# `iptables`, `ip6tables`, and `ipset`
			if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/ipset -L rhfw4csp | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/ipset add rhfw4csp $THIS_IP && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			# `nftables`
			elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/nft list set ip filter rhfw4csp | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/nft add element ip filter rhfw4csp { $THIS_IP } && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			fi
		elif [[ $SINGLE_OR_RANGE == "range" ]]; then
			# `iptables`, `ip6tables`, and `ipset`
			if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/ipset -L rhfw4crp | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/ipset add rhfw4crp $THIS_IP && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			# `nftables`
			elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/nft list set ip filter rhfw4crp | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/nft add element ip filter rhfw4crp { $THIS_IP } && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			fi
		fi
		# Add it to the text file of (perm) blocked IPs 
		if [[ $( /usr/bin/grep -Eq "^$THIS_IP" /opt/rh-firewall/rhfw_v4_custom-perm.txt && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/bin/echo "$THIS_IP" >> /opt/rh-firewall/rhfw_v4_custom-perm.txt
		fi
	fi
}

# Remove an IPv4 address or range from the permanent block list
function delIPv4 () {
	# Passed variables
	THIS_IP=$1
	SINGLE_OR_RANGE=$2
	# Single IP or Range?
	if [[ $SINGLE_OR_RANGE == "single" ]]; then
		# `iptables`, `ip6tables`, and `ipset`
		if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
			# Does IP already exist in set?
			if [[ $( /usr/sbin/ipset -L rhfw4csp | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
				/usr/sbin/ipset del rhfw4csp $THIS_IP && /usr/bin/echo "SUCCESS: '$THIS_IP' removed from block list" || /usr/bin/echo "ERROR: could not remove '$THIS_IP' from block list"
			else
				/usr/bin/echo "ERROR: '$THIS_IP' not found in block list"
			fi
		# `nftables`
		elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
			# Does IP already exist in set?
			if [[ $( /usr/sbin/nft list set ip filter rhfw4csp | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
				/usr/sbin/nft delete element ip filter rhfw4csp { $THIS_IP } && /usr/bin/echo "SUCCESS: '$THIS_IP' removed from block list" || /usr/bin/echo "ERROR: could not remove '$THIS_IP' from block list"
			else
				/usr/bin/echo "ERROR: '$THIS_IP' not found in block list"
			fi
		fi
	elif [[ $SINGLE_OR_RANGE == "range" ]]; then
		# `iptables`, `ip6tables`, and `ipset`
		if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
			# Does IP already exist in set?
			if [[ $( /usr/sbin/ipset -L rhfw4crp | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
				/usr/sbin/ipset del rhfw4crp $THIS_IP && /usr/bin/echo "SUCCESS: '$THIS_IP' removed from block list" || /usr/bin/echo "ERROR: could not remove '$THIS_IP' from block list"
			else
				/usr/bin/echo "ERROR: '$THIS_IP' not found in block list"
			fi
		# `nftables`
		elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
			# Does IP already exist in set?
			if [[ $( /usr/sbin/nft list set ip filter rhfw4crp | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
				/usr/sbin/nft delete element ip filter rhfw4crp { $THIS_IP } && /usr/bin/echo "SUCCESS: '$THIS_IP' removed from block list" || /usr/bin/echo "ERROR: could not remove '$THIS_IP' from block list"
			else
				/usr/bin/echo "ERROR: '$THIS_IP' not found in block list"
			fi
		fi
	fi
	# Delete it from the text file of (perm) blocked IPs
	if [[ $( /usr/bin/grep -Eq "^$THIS_IP" /opt/rh-firewall/rhfw_v4_custom-perm.txt && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
		THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
		/usr/bin/perl -ni -e "print unless /$THIS_IP/" /opt/rh-firewall/rhfw_v4_custom-perm.txt
	fi
}

# Add an IPv6 address or range to the appropritate permanent or temporary block lists
function addIPv6 () {
	# Passed variables
	THIS_IP=$1
	SINGLE_OR_RANGE=$2
	PERM_OR_TEMP=$3
	HOURS_TO_BLOCK=$4
	# Compress IPv6
	THIS_IPV6_ZERO_STRIPPED=$(/usr/bin/echo "$THIS_IP" | /usr/bin/perl -p -e "s/^0{1,3}(?=[a-z0-9])//g" | /usr/bin/perl -p -e "s/:0{1,3}(?=[a-z0-9])/:/g" )
	THIS_IPV6_LONGEST_ZERO=""
	if [[ $( /usr/bin/echo $THIS_IPV6_ZERO_STRIPPED | /usr/bin/grep -q "::" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
		THIS_IPV6_LONGEST_ZERO="::"
	else
		THIS_IPV6_LONGEST_ZERO=$( /usr/bin/echo $THIS_IPV6_ZERO_STRIPPED | /usr/bin/grep -Po "((^|:)0){1,}:" | /usr/bin/sort -r | /usr/bin/head -n +1)
	fi
	if [[ $THIS_IPV6_LONGEST_ZERO != "" && THIS_IPV6_LONGEST_ZERO != "::" ]]; then 
		THIS_IP=$( /usr/bin/echo $THIS_IPV6_ZERO_STRIPPED | /usr/bin/perl -p -e "s/$THIS_IPV6_LONGEST_ZERO/::/")
	else
		THIS_IP=$THIS_IPV6_ZERO_STRIPPED
	fi
	# permanent block or temporary?
	if [[ $PERM_OR_TEMP == "temp" ]]; then
		# Time to lift temporary blocks
		UNBLOCK_TIME=$( /usr/bin/date -d "+$HOURS_TO_BLOCK hour" '+%s' )
		# Single IP or Range?
		if [[ $SINGLE_OR_RANGE == "single" ]]; then
			# `iptables`, `ip6tables`, and `ipset`
			if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/ipset -L rhfw6cst | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/ipset add rhfw6cst $THIS_IP && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			# `nftables`
			elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/nft list set ip6 filter rhfw6cst | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/nft add element ip6 filter rhfw6cst { $THIS_IP } && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			fi
		elif [[ $SINGLE_OR_RANGE == "range" ]]; then
			# `iptables`, `ip6tables`, and `ipset`
			if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/ipset -L rhfw6crt | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/ipset add rhfw6crt $THIS_IP && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			# `nftables`
			elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/nft list set ip6 filter rhfw6crt | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/nft add element ip6 filter rhfw6crt { $THIS_IP } && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			fi
		fi
		# Add it to the text file of (temp) blocked IPs 
		if [[ $( /usr/bin/grep -Eq "^$THIS_IP" /opt/rh-firewall/rhfw_v6_custom-temp.csv && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/bin/echo "$THIS_IP,$UNBLOCK_TIME" >> /opt/rh-firewall/rhfw_v6_custom-temp.csv
		# But if it already exists...
		else
			# Remove and re-add it with the new timestamp
			THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
			/usr/bin/perl -ni -e "print unless /^$THIS_IP\,[0-9]+$/" /opt/rh-firewall/rhfw_v6_custom-temp.csv
			/usr/bin/echo "$THIS_IP,$UNBLOCK_TIME" >> /opt/rh-firewall/rhfw_v6_custom-temp.csv
		fi
	else
		# Single IP or Range?
		if [[ $SINGLE_OR_RANGE == "single" ]]; then
			# `iptables`, `ip6tables`, and `ipset`
			if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/ipset -L rhfw6csp | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/ipset add rhfw6csp $THIS_IP && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			# `nftables`
			elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/nft list set ip6 filter rhfw6csp | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/nft add element ip6 filter rhfw6csp { $THIS_IP } && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			fi
		elif [[ $SINGLE_OR_RANGE == "range" ]]; then
			# `iptables`, `ip6tables`, and `ipset`
			if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/ipset -L rhfw6crp | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/ipset add rhfw6crp $THIS_IP && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			# `nftables`
			elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
				# Does IP already exist in set?
				if [[ $( /usr/sbin/nft list set ip6 filter rhfw6crp | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
					/usr/sbin/nft add element ip6 filter rhfw6crp { $THIS_IP } && /usr/bin/echo "SUCCESS: '$THIS_IP' added to block list" || /usr/bin/echo "ERROR: could not add '$THIS_IP' to block list"
				fi
			fi
		fi
		# Add it to the text file of (perm) blocked IPs 
		if [[ $( /usr/bin/grep -Eq "^$THIS_IP" /opt/rh-firewall/rhfw_v6_custom-perm.txt && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
			/usr/bin/echo "$THIS_IP" >> /opt/rh-firewall/rhfw_v6_custom-perm.txt
		fi
	fi
}

# Remove an IPv6 address or range from the permanent block list
function delIPv6 () {
	# Passed variables
	THIS_IP=$1
	SINGLE_OR_RANGE=$2
	# Compress IPv6
	THIS_IPV6_ZERO_STRIPPED=$(/usr/bin/echo "$THIS_IP" | /usr/bin/perl -p -e "s/^0{1,3}(?=[a-z0-9])//g" | /usr/bin/perl -p -e "s/:0{1,3}(?=[a-z0-9])/:/g" )
	THIS_IPV6_LONGEST_ZERO=""
	if [[ $( /usr/bin/echo $THIS_IPV6_ZERO_STRIPPED | /usr/bin/grep -q "::" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
		THIS_IPV6_LONGEST_ZERO="::"
	else
		THIS_IPV6_LONGEST_ZERO=$( /usr/bin/echo $THIS_IPV6_ZERO_STRIPPED | /usr/bin/grep -Po "((^|:)0){1,}:" | /usr/bin/sort -r | /usr/bin/head -n +1)
	fi
	if [[ $THIS_IPV6_LONGEST_ZERO != "" && THIS_IPV6_LONGEST_ZERO != "::" ]]; then 
		THIS_IP=$( /usr/bin/echo $THIS_IPV6_ZERO_STRIPPED | /usr/bin/perl -p -e "s/$THIS_IPV6_LONGEST_ZERO/::/")
	else
		THIS_IP=$THIS_IPV6_ZERO_STRIPPED
	fi
	# Single IP or Range?
	if [[ $SINGLE_OR_RANGE == "single" ]]; then
		# `iptables`, `ip6tables`, and `ipset`
		if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
			# Does IP already exist in set?
			if [[ $( /usr/sbin/ipset -L rhfw6csp | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
				/usr/sbin/ipset del rhfw6csp $THIS_IP && /usr/bin/echo "SUCCESS: '$THIS_IP' removed from block list" || /usr/bin/echo "ERROR: could not remove '$THIS_IP' from block list"
			else
				/usr/bin/echo "ERROR: '$THIS_IP' not found in block list"
			fi
		# `nftables`
		elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
			# Does IP already exist in set?
			if [[ $( /usr/sbin/nft list set ip6 filter rhfw6csp | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
				/usr/sbin/nft delete element ip6 filter rhfw6csp { $THIS_IP } && /usr/bin/echo "SUCCESS: '$THIS_IP' removed from block list" || /usr/bin/echo "ERROR: could not remove '$THIS_IP' from block list"
			else
				/usr/bin/echo "ERROR: '$THIS_IP' not found in block list"
			fi
		fi
	elif [[ $SINGLE_OR_RANGE == "range" ]]; then
		# `iptables`, `ip6tables`, and `ipset`
		if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
			# Does IP already exist in set?
			if [[ $( /usr/sbin/ipset -L rhfw6crp | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
				/usr/sbin/ipset del rhfw6crp $THIS_IP && /usr/bin/echo "SUCCESS: '$THIS_IP' removed from block list" || /usr/bin/echo "ERROR: could not remove '$THIS_IP' from block list"
			else
				/usr/bin/echo "ERROR: '$THIS_IP' not found in block list"
			fi
		# `nftables`
		elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
			# Does IP already exist in set?
			if [[ $( /usr/sbin/nft list set ip6 filter rhfw6crp | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
				/usr/sbin/nft delete element ip6 filter rhfw6crp { $THIS_IP } && /usr/bin/echo "SUCCESS: '$THIS_IP' removed from block list" || /usr/bin/echo "ERROR: could not remove '$THIS_IP' from block list"
			else
				/usr/bin/echo "ERROR: '$THIS_IP' not found in block list"
			fi
		fi
	fi
	# Delete it from the text file of (perm) blocked IPs
	if [[ $( /usr/bin/grep -Eq "^$THIS_IP" /opt/rh-firewall/rhfw_v6_custom-perm.txt && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
		THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
		/usr/bin/perl -ni -e "print unless /$THIS_IP/" /opt/rh-firewall/rhfw_v6_custom-perm.txt
	fi
}

# Load in the perm block lists
function loadPerm () {
	# Remove IPs from sets that no longer exist in the list
	# `iptables`, `ip6tables`, and `ipset` OR `nftables`
	if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
		# Remove single IPs that don't exist in "/opt/rh-firewall/rhfw_v4_custom-perm.txt" from "rhfw4csp"
		/usr/sbin/ipset -L rhfw4csp | /usr/bin/grep -Eo "^([0-9]{1,3}\.){3}([0-9]{1,3}){1}$" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP$" /opt/rh-firewall/rhfw_v4_custom-perm.txt && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				delIPv4 $THIS_IP "single"
			fi
		done
		# Remove IP ranges that don't exist in "/opt/rh-firewall/rhfw_v4_custom-perm.txt" from "rhfw4crp"
		/usr/sbin/ipset -L rhfw4crp | /usr/bin/grep -Eo "^([0-9]{1,3}\.){3}([0-9]{1,3}){1}(\/[0-9]{1,2}){1}$" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP$" /opt/rh-firewall/rhfw_v4_custom-perm.txt && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				delIPv4 $THIS_IP "range"
			fi
		done
		# Remove single IPs that don't exist in "/opt/rh-firewall/rhfw_v6_custom-perm.txt" from "rhfw6csp"
		/usr/sbin/ipset -L rhfw6csp | /usr/bin/grep -Eo "^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}$" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP$" /opt/rh-firewall/rhfw_v6_custom-perm.txt && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				delIPv6 $THIS_IP "single"
			fi
		done
		# Remove IP ranges that don't exist in "/opt/rh-firewall/rhfw_v6_custom-perm.txt" from "rhfw6crp"
		/usr/sbin/ipset -L rhfw6crp | /usr/bin/grep -Eo "^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/[0-9]{1,2}){1}$" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP$" /opt/rh-firewall/rhfw_v6_custom-perm.txt && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				delIPv6 $THIS_IP "range"
			fi
		done
	# `nftables`
	elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
		# Remove single IPs that don't exist in "/opt/rh-firewall/rhfw_v4_custom-perm.txt" from "rhfw4csp"
		/usr/sbin/nft list set ip filter rhfw4csp | /usr/bin/grep -Po "(?<= )([0-9]{1,3}\.){3}([0-9]{1,3}){1}(?=( |,))" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP$" /opt/rh-firewall/rhfw_v4_custom-perm.txt && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				delIPv4 $THIS_IP "single"
			fi
		done
		# Remove IP ranges that don't exist in "/opt/rh-firewall/rhfw_v4_custom-perm.txt" from "rhfw4crp"
		/usr/sbin/nft list set ip filter rhfw4crp | /usr/bin/grep -Po "(?<= )([0-9]{1,3}\.){3}([0-9]{1,3}){1}(\/[0-9]{1,2}){1}(?=( |,))" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP$" /opt/rh-firewall/rhfw_v4_custom-perm.txt && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				delIPv4 $THIS_IP "range"
			fi
		done
		# Remove single IPs that don't exist in "/opt/rh-firewall/rhfw_v6_custom-perm.txt" from "rhfw6csp"
		/usr/sbin/nft list set ip6 filter rhfw6csp | /usr/bin/grep -Po "(?<= )([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(?=( |,))" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP$" /opt/rh-firewall/rhfw_v6_custom-perm.txt && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				delIPv6 $THIS_IP "single"
			fi
		done
		# Remove IP ranges that don't exist in "/opt/rh-firewall/rhfw_v6_custom-perm.txt" from "rhfw6crp"
		/usr/sbin/nft list set ip6 filter rhfw6crp | /usr/bin/grep -Po "(?<= )([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/[0-9]{1,2}){1}(?=( |,))" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP$" /opt/rh-firewall/rhfw_v6_custom-perm.txt && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				delIPv6 $THIS_IP "range"
			fi
		done
	fi
	# Read through "/opt/rh-firewall/rhfw_v4_custom-perm.txt" and add IPs
	/usr/bin/cat /opt/rh-firewall/rhfw_v4_custom-perm.txt | while read THIS_IP; do
		if [[ $THIS_IP =~ ^([0-9]{1,3}\.){3}([0-9]{1,3}){1}$ ]]; then
			addIPv4 $THIS_IP "single" "perm" "0"
		elif [[ $THIS_IP =~ ^([0-9]{1,3}\.){3}([0-9]{1,3}){1}(\/[0-9]{1,2}){1}$ ]]; then
			addIPv4 $THIS_IP "range" "perm" "0"
		fi
	done
	# Read through "/opt/rh-firewall/rhfw_v6_custom-perm.txt" and add IPs
	/usr/bin/cat /opt/rh-firewall/rhfw_v6_custom-perm.txt | while read THIS_IP; do
		if [[ $THIS_IP =~ ^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}$ ]]; then
			addIPv6 $THIS_IP "single" "perm" "0"
		elif [[ $THIS_IP =~ ^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/[0-9]{1,2}){1}$ ]]; then
			addIPv6 $THIS_IP "range" "perm" "0"
		fi
	done
}

# List all IPs that are blocked
function listBlocks () {
	# Passed variables
	THIS_SET=$1
	# `iptables`, `ip6tables`, and `ipset`
	if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
		# If a valid set name was passed...
		if [[ -n $THIS_SET && $THIS_SET =~ ^rhfw(4|6)(c|d).+$ ]]; then
			# And if that set exists...
			if [[ $( /usr/sbin/ipset -L -n | /usr/bin/grep -Eq "^$THIS_SET$" | /usr/bin/uniq && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"FALSE"* ]]; then
				# List out all IPs in that set
				/usr/sbin/ipset -L $THIS_SET | /usr/bin/grep -Eo "^((([0-9]{1,3}\.){3}([0-9]{1,3}){1})|(([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}))(\/[0-9]{1,2}){0,1}$" | /usr/bin/uniq 
			else
				/usr/bin/echo "ERROR: set '$1' does not exist"
			fi
		# If no set was passed
		elif [[ -z $THIS_SET ]]; then
			# Get 'em all
			/usr/sbin/ipset -L -n | /usr/bin/grep -E "^rhfw" | /usr/bin/uniq | while read THIS_RHFW_SET; do
				# And list out all IPs in each set
				/usr/sbin/ipset -L $THIS_RHFW_SET | /usr/bin/grep -Eo "^((([0-9]{1,3}\.){3}([0-9]{1,3}){1})|(([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}))(\/[0-9]{1,2}){0,1}$" | /usr/bin/uniq | while read THIS_RHFW_SET_IP; do
					# And print them in a CSV
					/usr/bin/echo "$THIS_RHFW_SET,$THIS_RHFW_SET_IP"
				done
			done
		else
			/usr/bin/echo "ERROR: set '$THIS_SET' is not managed by rh-firewall"
		fi
	# `nftables`
	elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
		# If a valid set name was passed...
		if [[ -n $THIS_SET && $THIS_SET =~ ^rhfw(4|6)(c|d).+$ ]]; then
			# If it is an IPv4 set
			if [[ $THIS_SET =~ ^rhfw4(c|d).+$ && $( /usr/sbin/nft list set ip filter $THIS_SET 2>/dev/null | /usr/bin/grep -Poq "(?<=set )rhfw.+(?=\{)" | /usr/bin/uniq && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"FALSE"* ]]; then
				/usr/sbin/nft list set ip filter $THIS_SET | /usr/bin/grep -Po "(?<= )(([0-9]{1,3}\.){3}([0-9]{1,3}){1})(\/[0-9]{1,2}){0,1}(?=( |,))" | /usr/bin/uniq
			# If it is an IPv6 set
			elif [[ $THIS_SET =~ ^rhfw6(c|d).+$ && $( /usr/sbin/nft list set ip6 filter $THIS_SET 2>/dev/null | /usr/bin/grep -Poq "(?<=set )rhfw.+(?=\{)" | /usr/bin/uniq && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"FALSE"* ]]; then
				/usr/sbin/nft list set ip6 filter $THIS_SET | /usr/bin/grep -Po "(?<= )([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/[0-9]{1,2}){0,1}(?=( |,))" | /usr/bin/uniq
			else
				/usr/bin/echo "ERROR: set '$THIS_SET' does not exist"
			fi
		# If no set was passed
		elif [[ -z $THIS_SET ]]; then
			# Get 'em all (IPv4)
			/usr/sbin/nft list sets ip | /usr/bin/grep -Po "(?<=set )rhfw.+(?=\{)" | /usr/bin/uniq | while read THIS_RHFW4_SET; do
				# And list out all IPs in each set
				/usr/sbin/nft list set ip filter $THIS_RHFW4_SET | /usr/bin/grep -Po "(?<= )(([0-9]{1,3}\.){3}([0-9]{1,3}){1})(\/[0-9]{1,2}){0,1}(?=( |,))" | /usr/bin/uniq | while read THIS_RHFW4_SET_IP; do
					# And print them in a CSV
					/usr/bin/echo "$THIS_RHFW4_SET,$THIS_RHFW4_SET_IP"
				done
			done
			# Get 'em all (IPv6)
			/usr/sbin/nft list sets ip6 | /usr/bin/grep -Po "(?<=set )rhfw.+(?=\{)" | /usr/bin/uniq | while read THIS_RHFW6_SET; do
				# And list out all IPs in each set
				/usr/sbin/nft list set ip6 filter $THIS_RHFW6_SET | /usr/bin/grep -Po "(?<= )([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/[0-9]{1,2}){0,1}(?=( |,))" | /usr/bin/uniq | while read THIS_RHFW6_SET_IP; do
					# And print them in a CSV
					/usr/bin/echo "$THIS_RHFW6_SET,$THIS_RHFW6_SET_IP"
				done
			done
		else
			/usr/bin/echo "ERROR: set '$THIS_SET' is not managed by rh-firewall"
		fi
	fi
}

# Switch to `nftables` from `iptables`
function nftToggle () {
	# Is it already using `nftables`?
	if [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
		/usr/bin/echo "NOTICE: allready using 'nftables'"
	# Is it currently using `iptables` and is `nftables` installed?
	elif [[ $IPTABLES_OR_NFTABLES == "iptables" && $( /usr/bin/which nft 1>/dev/null && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
		# Touch the flag file to force use of `nftables` when it'd otherwise use `iptables`
		/usr/bin/touch /opt/rh-firewall/rhfwnft.flag
		# Set the variable
		IPTABLES_OR_NFTABLES="nftables"
		# Delete iptables IPv4 Rules
		/usr/sbin/iptables -S | /usr/bin/grep -E "rhfw4(c|d)" | /usr/bin/sed "s/^\-[AI]/\-D/" | while read DEL_THIS_IPTABLES_RULE; do
			/usr/sbin/iptables $DEL_THIS_IPTABLES_RULE
		done
		# Delete iptables IPv6 Rules
		/usr/sbin/ip6tables -S | /usr/bin/grep -E "rhfw6(c|d)" | /usr/bin/sed "s/^\-[AI]/\-D/" | while read DEL_THIS_IP6TABLES_RULE; do
			/usr/sbin/ip6tables $DEL_THIS_IP6TABLES_RULE
		done
		# Delete IPSets
		/usr/sbin/ipset -L -n | /usr/bin/grep -E "^rhfw(6|4)(c|d)" | while read DEL_THIS_IPSET; do
			/usr/sbin/ipset destroy $DEL_THIS_IPSET
		done
		# Restart the service
		/usr/bin/systemctl restart rh-firewall.service 
	else
		/usr/bin/echo "ERROR: 'nftables' is not installed"
	fi
}

# Refresh/load in the temporary block lists
function refreshTemp () {
	# Variables
	CURRENT_TIMESTAMP=$( /usr/bin/date '+%s' )
	# `iptables`, `ip6tables`, and `ipset`
	if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
		# Refresh IPv4 blocks
		/usr/bin/cat /opt/rh-firewall/rhfw_v4_custom-temp.csv | while read THIS_LINE; do
			# Split IP from Timestamp
			THIS_IP=$( /usr/bin/echo $THIS_LINE | /usr/bin/awk -F',' '{print $1}' )
			THIS_TIMESTAMP=$( /usr/bin/echo $THIS_LINE | /usr/bin/awk -F',' '{print $2}' )
			# Match single IP or range?
			if [[ $THIS_IP =~ ^([0-9]{1,3}\.){3}([0-9]{1,3}){1}$ ]]; then
				# If it's after the expire time...
				if [[ $CURRENT_TIMESTAMP -ge $THIS_TIMESTAMP ]]; then
					# Does IP exist in set?
					if [[ $( /usr/sbin/ipset -L rhfw4cst | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
						/usr/sbin/ipset del rhfw4cst $THIS_IP
					fi
					THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
					/usr/bin/perl -ni -e "print unless /^$THIS_IP\,$THIS_TIMESTAMP$/" /opt/rh-firewall/rhfw_v4_custom-temp.csv
				# But if it's not...
				else
					# Make sure the block is still active...
					if [[ $( /usr/sbin/ipset -L rhfw4cst | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
						/usr/sbin/ipset add rhfw4cst $THIS_IP
					fi
				fi
			elif [[ $THIS_IP =~ ^([0-9]{1,3}\.){3}([0-9]{1,3}){1}(\/[0-9]{1,2}){1}$ ]]; then
				# If it's after the expire time...
				if [[ $CURRENT_TIMESTAMP -ge $THIS_TIMESTAMP ]]; then
					# Does IP exist in set?
					if [[ $( /usr/sbin/ipset -L rhfw4crt | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
						/usr/sbin/ipset del rhfw4crt $THIS_IP
					fi
					THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
					/usr/bin/perl -ni -e "print unless /^$THIS_IP\,$THIS_TIMESTAMP$/" /opt/rh-firewall/rhfw_v4_custom-temp.csv
				# But if it's not...
				else
					# Make sure the block is still active...
					if [[ $( /usr/sbin/ipset -L rhfw4crt | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
						/usr/sbin/ipset add rhfw4crt $THIS_IP
					fi
				fi
			fi
		done
		# Remove single IPs that don't exist in "/opt/rh-firewall/rhfw_v4_custom-temp.csv" from "rhfw4cst"
		/usr/sbin/ipset -L rhfw4cst | /usr/bin/grep -Eo "^([0-9]{1,3}\.){3}([0-9]{1,3}){1}$" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP\,[0-9]+$" /opt/rh-firewall/rhfw_v4_custom-temp.csv && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				/usr/sbin/ipset del rhfw4cst $THIS_IP
				THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
				/usr/bin/perl -ni -e "print unless /^$THIS_IP\,[0-9]+$/" /opt/rh-firewall/rhfw_v4_custom-temp.csv
			fi
		done
		# Remove IP ranges that don't exist in "/opt/rh-firewall/rhfw_v4_custom-temp.csv" from "rhfw4crt"
		/usr/sbin/ipset -L rhfw4crt | /usr/bin/grep -Eo "^([0-9]{1,3}\.){3}([0-9]{1,3}){1}(\/[0-9]{1,2}){1}$" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP\,[0-9]+$" /opt/rh-firewall/rhfw_v4_custom-temp.csv && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				/usr/sbin/ipset del rhfw4crt $THIS_IP
				THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
				/usr/bin/perl -ni -e "print unless /^$THIS_IP\,[0-9]+$/" /opt/rh-firewall/rhfw_v4_custom-temp.csv
			fi
		done
		# Refresh IPv6 blocks
		/usr/bin/cat /opt/rh-firewall/rhfw_v6_custom-temp.csv | while read THIS_LINE; do
			# Split IP from Timestamp
			THIS_IP=$( /usr/bin/echo $THIS_LINE | /usr/bin/awk -F',' '{print $1}' )
			THIS_TIMESTAMP=$( /usr/bin/echo $THIS_LINE | /usr/bin/awk -F',' '{print $2}' )
			# Match single IP or range?
			if [[ $THIS_IP =~ ^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}$ ]]; then
				# If it's after the expire time...
				if [[ $CURRENT_TIMESTAMP -ge $THIS_TIMESTAMP ]]; then
					# Does IP exist in set?
					if [[ $( /usr/sbin/ipset -L rhfw6cst | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
						/usr/sbin/ipset del rhfw6cst $THIS_IP
					fi
					THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
					/usr/bin/perl -ni -e "print unless /^$THIS_IP\,$THIS_TIMESTAMP$/" /opt/rh-firewall/rhfw_v6_custom-temp.csv
				# But if it's not...
				else
					# Make sure the block is still active...
					if [[ $( /usr/sbin/ipset -L rhfw6cst | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
						/usr/sbin/ipset add rhfw6cst $THIS_IP
					fi
				fi
			elif [[ $THIS_IP =~ ^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/[0-9]{1,2}){1}$ ]]; then
				# If it's after the expire time...
				if [[ $CURRENT_TIMESTAMP -ge $THIS_TIMESTAMP ]]; then
					# Does IP exist in set?
					if [[ $( /usr/sbin/ipset -L rhfw6crt | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
						/usr/sbin/ipset del rhfw6crt $THIS_IP
					fi
					THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
					/usr/bin/perl -ni -e "print unless /^$THIS_IP\,$THIS_TIMESTAMP$/" /opt/rh-firewall/rhfw_v6_custom-temp.csv
				# But if it's not...
				else
					# Make sure the block is still active...
					if [[ $( /usr/sbin/ipset -L rhfw6crt | /usr/bin/grep -Eq "^$THIS_IP$" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
						/usr/sbin/ipset add rhfw6crt $THIS_IP
					fi
				fi
			fi
		done
		# Remove single IPs that don't exist in "/opt/rh-firewall/rhfw_v6_custom-temp.csv" from "rhfw6cst"
		/usr/sbin/ipset -L rhfw6cst | /usr/bin/grep -Eo "^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}$" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP\,[0-9]+$" /opt/rh-firewall/rhfw_v6_custom-temp.csv && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				/usr/sbin/ipset del rhfw6cst $THIS_IP
				THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
				/usr/bin/perl -ni -e "print unless /$THIS_IP\,[0-9]+$/" /opt/rh-firewall/rhfw_v6_custom-temp.csv
			fi
		done
		# Remove IP ranges that don't exist in "/opt/rh-firewall/rhfw_v6_custom-temp.csv" from "rhfw6crt"
		/usr/sbin/ipset -L rhfw6crt | /usr/bin/grep -Eo "^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/[0-9]{1,2}){1}$" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP\,[0-9]+$" /opt/rh-firewall/rhfw_v6_custom-temp.csv && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				/usr/sbin/ipset del rhfw6crt $THIS_IP
				THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
				/usr/bin/perl -ni -e "print unless /^$THIS_IP\,[0-9]+$/" /opt/rh-firewall/rhfw_v6_custom-temp.csv
			fi
		done
	# `nftables`
	elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
		# Refresh IPv4 blocks
		/usr/bin/cat /opt/rh-firewall/rhfw_v4_custom-temp.csv | while read THIS_LINE; do
			# Split IP from Timestamp
			THIS_IP=$( /usr/bin/echo $THIS_LINE | /usr/bin/awk -F',' '{print $1}' )
			THIS_TIMESTAMP=$( /usr/bin/echo $THIS_LINE | /usr/bin/awk -F',' '{print $2}' )
			# Match single IP or range?
			if [[ $THIS_IP =~ ^([0-9]{1,3}\.){3}([0-9]{1,3}){1}$ ]]; then
				# If it's after the expire time...
				if [[ $CURRENT_TIMESTAMP -ge $THIS_TIMESTAMP ]]; then
					# Does IP already exist in set?
					if [[ $( /usr/sbin/nft list set ip filter rhfw4cst | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
						/usr/sbin/nft delete element ip filter rhfw4cst { $THIS_IP }
					fi
					THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
					/usr/bin/perl -ni -e "print unless /^$THIS_IP\,$THIS_TIMESTAMP$/" /opt/rh-firewall/rhfw_v4_custom-temp.csv
				# But if it's not...
				else
					# Make sure the block is still active...
					if [[ $( /usr/sbin/nft list set ip filter rhfw4cst | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
						/usr/sbin/nft add element ip filter rhfw4cst { $THIS_IP }
					fi
				fi
			elif [[ $THIS_IP =~ ^([0-9]{1,3}\.){3}([0-9]{1,3}){1}(\/[0-9]{1,2}){1}$ ]]; then
				# If it's after the expire time...
				if [[ $CURRENT_TIMESTAMP -ge $THIS_TIMESTAMP ]]; then
					# Does IP already exist in set?
					if [[ $( /usr/sbin/nft list set ip filter rhfw4crt | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
						/usr/sbin/nft delete element ip filter rhfw4crt { $THIS_IP }
					fi
					THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
					/usr/bin/perl -ni -e "print unless /^$THIS_IP\,$THIS_TIMESTAMP$/" /opt/rh-firewall/rhfw_v4_custom-temp.csv
				# But if it's not...
				else
					# Make sure the block is still active...
					if [[ $( /usr/sbin/nft list set ip filter rhfw4crt | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
						/usr/sbin/nft add element ip filter rhfw4crt { $THIS_IP }
					fi
				fi
			fi
		done
		# Remove single IPs that don't exist in "/opt/rh-firewall/rhfw_v4_custom-temp.csv" from "rhfw4cst"
		/usr/sbin/nft list set ip filter rhfw4cst | /usr/bin/grep -Po "(?<= )([0-9]{1,3}\.){3}([0-9]{1,3}){1}(?=( |,))" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP\,[0-9]+$" /opt/rh-firewall/rhfw_v4_custom-temp.csv && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				/usr/sbin/nft delete element ip filter rhfw4cst { $THIS_IP }
				THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
				/usr/bin/perl -ni -e "print unless /^$THIS_IP\,[0-9]+$/" /opt/rh-firewall/rhfw_v4_custom-temp.csv
			fi
		done
		# Remove IP ranges that don't exist in "/opt/rh-firewall/rhfw_v4_custom-temp.csv" from "rhfw4crt"
		/usr/sbin/nft list set ip filter rhfw4crt | /usr/bin/grep -Po "(?<= )([0-9]{1,3}\.){3}([0-9]{1,3}){1}(\/[0-9]{1,2}){1}(?=( |,))" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP\,[0-9]+$" /opt/rh-firewall/rhfw_v4_custom-temp.csv && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				/usr/sbin/nft delete element ip filter rhfw4crt { $THIS_IP }
				THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
				/usr/bin/perl -ni -e "print unless /^$THIS_IP\,[0-9]+$/" /opt/rh-firewall/rhfw_v4_custom-temp.csv
			fi
		done
		# Refresh IPv6 blocks
		/usr/bin/cat /opt/rh-firewall/rhfw_v6_custom-temp.csv | while read THIS_LINE; do
			# Split IP from Timestamp
			THIS_IP=$( /usr/bin/echo $THIS_LINE | /usr/bin/awk -F',' '{print $1}' )
			THIS_TIMESTAMP=$( /usr/bin/echo $THIS_LINE | /usr/bin/awk -F',' '{print $2}' )
			# Match single IP or range?
			if [[ $THIS_IP =~ ^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}$ ]]; then
				# If it's after the expire time...
				if [[ $CURRENT_TIMESTAMP -ge $THIS_TIMESTAMP ]]; then
					# Does IP already exist in set?
					if [[ $( /usr/sbin/nft list set ip6 filter rhfw6cst | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
						/usr/sbin/nft delete element ip6 filter rhfw6cst { $THIS_IP }
					fi
					THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
					/usr/bin/perl -ni -e "print unless /^$THIS_IP\,$THIS_TIMESTAMP$/" /opt/rh-firewall/rhfw_v6_custom-temp.csv
				# But if it's not...
				else
					# Make sure the block is still active...
					if [[ $( /usr/sbin/nft list set ip6 filter rhfw6cst | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
						/usr/sbin/nft add element ip6 filter rhfw6cst { $THIS_IP }
					fi
				fi
			elif [[ $THIS_IP =~ ^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/[0-9]{1,2}){1}$ ]]; then
				# If it's after the expire time...
				if [[ $CURRENT_TIMESTAMP -ge $THIS_TIMESTAMP ]]; then
					# Does IP already exist in set?
					if [[ $( /usr/sbin/nft list set ip6 filter rhfw6crt | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) == *"TRUE"* ]]; then
						/usr/sbin/nft delete element ip6 filter rhfw6crt { $THIS_IP }
					fi
					THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
					/usr/bin/perl -ni -e "print unless /^$THIS_IP\,$THIS_TIMESTAMP$/" /opt/rh-firewall/rhfw_v6_custom-temp.csv
				# But if it's not...
				else
					# Make sure the block is still active...
					if [[ $( /usr/sbin/nft list set ip6 filter rhfw6crt | /usr/bin/grep -Eq " $THIS_IP( |,)" && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then
						/usr/sbin/nft add element ip6 filter rhfw6crt { $THIS_IP }
					fi
				fi
			fi
		done
		# Remove single IPs that don't exist in "/opt/rh-firewall/rhfw_v6_custom-temp.csv" from "rhfw6cst"
		/usr/sbin/nft list set ip6 filter rhfw6cst | /usr/bin/grep -Po "(?<= )([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(?=( |,))" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP\,[0-9]+$" /opt/rh-firewall/rhfw_v6_custom-temp.csv && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				/usr/sbin/nft delete element ip6 filter rhfw6cst { $THIS_IP }
				THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
				/usr/bin/perl -ni -e "print unless /^$THIS_IP\,[0-9]+$/" /opt/rh-firewall/rhfw_v6_custom-temp.csv
			fi
		done
		# Remove IP ranges that don't exist in "/opt/rh-firewall/rhfw_v6_custom-temp.csv" from "rhfw6crt"
		/usr/sbin/nft list set ip6 filter rhfw6crt | /usr/bin/grep -Po "(?<= )([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/[0-9]{1,2}){1}(?=( |,))" | while read THIS_IP; do
			if [[ $( /usr/bin/grep -Eq "^$THIS_IP\,[0-9]+$" /opt/rh-firewall/rhfw_v6_custom-temp.csv && /usr/bin/echo "TRUE" || /usr/bin/echo "FALSE" ) != *"TRUE"* ]]; then 
				/usr/sbin/nft delete element ip6 filter rhfw6crt { $THIS_IP }
				THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\//\\\\\//g" | /usr/bin/perl -p -e "s/\./\\\./g" )
				/usr/bin/perl -ni -e "print unless /^$THIS_IP\,[0-9]+$/" /opt/rh-firewall/rhfw_v6_custom-temp.csv
			fi
		done
	fi
}

# Installer/updater
function selfInstall () {
	# Check if directory exists or not
	if [[ -d /opt/rh-firewall ]]; then
		# Pull any changes
		/usr/bin/git -C /opt/rh-firewall pull
		# Check perms on all other files
		/usr/bin/chown -R root: /opt/rh-firewall/
		/usr/bin/chmod -R 600 /opt/rh-firewall/
		/usr/bin/chmod 644  /opt/rh-firewall/rh-firewall.service
		# Make the scripts executable
		/usr/bin/chmod 700 /opt/rh-firewall/rhfw.sh
		/usr/bin/chmod 700 /opt/rh-firewall/rh-firewall.sh
		# Restart the service
		/usr/bin/systemctl daemon-reload
		/usr/bin/systemctl restart rh-firewall.service
	# If not, it must not be installed
	else
		# Clone the repo into the expected place
		/usr/bin/git clone https://github.com/reclaimhosting/rh-firewall.git /opt/rh-firewall
		# Check perms on all other files
		/usr/bin/chown -R root: /opt/rh-firewall/
		/usr/bin/chmod -R 600 /opt/rh-firewall/
		/usr/bin/chmod 644  /opt/rh-firewall/rh-firewall.service
		# Make the scripts executable
		/usr/bin/chmod 700 /opt/rh-firewall/rhfw.sh
		/usr/bin/chmod 700 /opt/rh-firewall/rh-firewall.sh
		# Link the service file into place
		/usr/bin/ln -s /opt/rh-firewall/rh-firewall.service /etc/systemd/system/rh-firewall.service
		# Enable and start the service
		/usr/bin/systemctl daemon-reload
		/usr/bin/systemctl enable --now rh-firewall.service
		# Link `rhfw` to this script
		/usr/bin/ln -s /opt/rh-firewall/rhfw.sh /usr/local/bin/rhfw
	fi
}

# Uninstall
function selfUninstall () {
	# Check if directory exists or not
	if [[ -d /opt/rh-firewall ]]; then
		# Disable and stop the service
		/usr/bin/systemctl disable --now rh-firewall.service 
		# Remove the symlinks
		[[ -L /usr/local/bin/rhfw ]] && /usr/bin/unlink /usr/local/bin/rhfw || [[ -f /usr/local/bin/rhfw ]] && /usr/bin/rm /usr/local/bin/rhfw
		[[ -L /etc/systemd/system/rh-firewall.service ]] && /usr/bin/unlink /etc/systemd/system/rh-firewall.service || [[ -f /etc/systemd/system/rh-firewall.service ]] && /usr/bin/rm /etc/systemd/system/rh-firewall.service
		# `iptables`, `ip6tables`, and `ipset` OR `nftables`
		if [[ $IPTABLES_OR_NFTABLES == "iptables" ]]; then
			# Delete iptables IPv4 Rules
			/usr/sbin/iptables -S | /usr/bin/grep -E "rhfw4(c|d)" | /usr/bin/sed "s/^\-[AI]/\-D/" | while read DEL_THIS_IPTABLES_RULE; do
				/usr/sbin/iptables $DEL_THIS_IPTABLES_RULE
			done
			# Delete iptables IPv6 Rules
			/usr/sbin/ip6tables -S | /usr/bin/grep -E "rhfw6(c|d)" | /usr/bin/sed "s/^\-[AI]/\-D/" | while read DEL_THIS_IP6TABLES_RULE; do
				/usr/sbin/ip6tables $DEL_THIS_IP6TABLES_RULE
			done
			# Delete IPSets
			/usr/sbin/ipset -L -n | /usr/bin/grep -E "^rhfw(6|4)(c|d)" | while read DEL_THIS_IPSET; do
				/usr/sbin/ipset destroy $DEL_THIS_IPSET
			done
		# `nftables`
		elif [[ $IPTABLES_OR_NFTABLES == "nftables" ]]; then
			# List out all nftables rules (IPv4)
			/usr/sbin/nft list ruleset ip | /usr/bin/grep -Po "(?<=set )rhfw4(c|d).+(?=\{)" | /usr/bin/uniq | while read DEL_THIS_NFT_RULE; do
				# Get the NFTables Handle
				DEL_THIS_NFT_HANDLE=$(/usr/sbin/nft -n -a list chain ip filter INPUT | /usr/bin/grep -Po "(?<=ip saddr \@$DEL_THIS_NFT_RULE drop # handle )([0-9]+)(?=$)")
				# Delete the NFTables rule
				/usr/sbin/nft delete rule ip filter INPUT handle $DEL_THIS_NFT_HANDLE
				# Delete the NFTables set
				/usr/sbin/nft delete set ip filter $DEL_THIS_NFT_RULE
			done
			# List out all nftables rules (IPv6)
			/usr/sbin/nft list ruleset ip6 | /usr/bin/grep -Po "(?<=set )rhfw6(c|d).+(?=\{)" | /usr/bin/uniq | while read DEL_THIS_NFT_RULE; do
				# Get the NFTables Handle
				DEL_THIS_NFT_HANDLE=$(/usr/sbin/nft -n -a list chain ip6 filter INPUT | /usr/bin/grep -Po "(?<=ip6 saddr \@$DEL_THIS_NFT_RULE drop # handle )([0-9]+)(?=$)")
				# Delete the NFTables rule
				/usr/sbin/nft delete rule ip6 filter INPUT handle $DEL_THIS_NFT_HANDLE
				# Delete the NFTables set
				/usr/sbin/nft delete set ip6 filter $DEL_THIS_NFT_RULE
			done
		fi
		# Remove the directory
		[[ -d /opt/rh-firewall ]] && /usr/bin/rm -rf /opt/rh-firewall
	# If not, it must not be installed
	else
		/usr/bin/echo "ERROR: 'rh-firewall' not installed"
	fi
}

# Help information
function printHelp () {
	/usr/bin/cat << EOF
NAME:

	rhfw.sh			Block IPs in rh-firewall

AUTHORS:

	Written by		Chris Blankenship <chrisb@reclaimhosting.com>
				for Reclaim Hosting (www.reclaimhosting.com)

NOTES:

	This script provides the interface for Reclaim Hosting's custom
	firewall (rh-firewall); specifically, adding IPs (and ranges) to
	custom per-server blocklists.
	
	You can only specify one option at a time. If you have multiple
	options/arguments/flags all but the first will be ignored.

OPTIONS:

	--add4		<IPv4 ADDRESS>

		Adds an IPv4 Address (or CIDR Range) to the permanent block
		list.

	--del4		<IPv4 ADDRESS>

		Removes an IPv4 Address (or CIDR Range) from the permanent
		block list.

	--add6		<IPv6 ADDRESS>

		Adds an IPv6 Address (or CIDR Range) to the permanent block
		list.

	--del6		<IPv6 ADDRESS>

		Removes an IPv4 Address (or CIDR Range) from the permanent
		block list.

	--load

		Loads the permanent block lists from:
			/opt/rh-firewall/rhfw_v4_custom-perm.txt
			/opt/rh-firewall/rhfw_v6_custom-perm.txt

	--temp4		<IPv4 ADDRESS> [HOURS]

		Adds an IPv4 Address (or CIDR Range) to the temporary block
		list for the specified number of hours (defaults to 24).
	
	--temp6		<IPv6 ADDRESS> [HOURS]

		Adds an IPv6 Address (or CIDR Range) to the temporary block
		list for the specified number of hours (defaults to 24).

	--refresh
	
		Refreshes the temporary block list from the files at:
			/opt/rh-firewall/rhfw_v4_custom-temp.csv
			/opt/rh-firewall/rhfw_v6_custom-temp.csv

	--update
	
		Updates/installs Reclaim Hosting's custom firewall
		(rh-firewall).

	--uninstall
	
		Uninstall Reclaim Hosting's custom firewall (rh-firewall).

	--blocks	[SET NAME]
	
		Lists IPs currently blocked by Reclaim Hosting's
		cutom firewall (rh-firewall).

	--switch
	
		Switches the backend of 'rh-firewall' from 'iptables'
		to 'nftables' if the former would otherwise be used.

	--help

		Prints this help and then exits.

EXAMPLES:

	bash rhfw.sh --add4 '192.168.5.3'
	bash rhfw.sh --del4 '192.168.5.0/24'
	bash rhfw.sh --temp6 'fd12:3456:789a:1::1' '36'
	bash rhfw.sh --load
	bash rhfw.sh --refresh

COPYRIGHT:

	Copyright (c) 2025, Reclaim Hosting <info@reclaimhosting.com>. All
	rights reserved. Licensed under the BSD License 2.0 (3-clause BSD
	License). This is free software; you are free to change and
	redistribuite it. THERE IS NO WARRANTY.

EOF
}

# Main function
function main () {
	# Ensure sets and rules exist
	setsExist
	rulesExist
	# If there are any CLI options/flags/arguments
	if [[ "$#" -gt 0 ]]; then
		# Loop through them
		while [[ "$#" -gt 0 ]]; do
			# --help/-h
			if [[ $1 =~ ^\-((\-(help|info))|(h|i))$ ]]; then
				# Print help
				printHelp
				# And then exit
				exit
			# --add4/-a
			elif [[ $1 =~ ^\-((\-(add|add4|a4))|(a))$ ]]; then
				# Get next in list
				shift
				# If that is a single IPv4 address
				if [[ $1 =~ ^([0-9]{1,3}\.){3}([0-9]{1,3}){1}(\/32){0,1}$ ]]; then
					# Strip /32 from the IP is it exists
					THIS_IP=$( /usr/bin/echo $1 | /usr/bin/perl -p -e "s/\/32$//g" )
					# Add the IP to the block list
					addIPv4 $THIS_IP "single" "perm" "0"
					# And then exit
					exit
				# If that is an IPv4 range
				elif [[ $1 =~ ^([0-9]{1,3}\.){3}([0-9]{1,3}){1}(\/[0-9]{1,2}){1}$ ]]; then
					# Add the IP to the block list
					addIPv4 $1 "range" "perm" "0"
					# And then exit
					exit
				# If it's neither
				else
					# Print error
					/usr/bin/echo "ERROR: '$1' does not appear to be an IPv4 address"
					# And exit
					exit
				fi
			# --del4/-d
			elif [[ $1 =~ ^\-((\-(del|del4|d4|delete|delete4))|(d))$ ]]; then
				# Get next in list
				shift
				# If that is a single IPv4 address
				if [[ $1 =~ ^([0-9]{1,3}\.){3}([0-9]{1,3}){1}(\/32){0,1}$ ]]; then
					# Strip /32 from the IP is it exists
					THIS_IP=$( /usr/bin/echo $1 | /usr/bin/perl -p -e "s/\/32$//g" )
					# Delete the IP from the block list
					delIPv4 $THIS_IP "single"
					# And then exit
					exit
				# If that is an actual IPv4 range
				elif [[ $1 =~ ^([0-9]{1,3}\.){3}([0-9]{1,3}){1}(\/[0-9]{1,2}){1}$ ]]; then
					# Delete the IP from the block list
					delIPv4 $1 "range"
					# And then exit
					exit
				# If it's neither
				else
					# Print error
					echo "ERROR: '$1' does not appear to be an IPv4 address"
					# And exit
					exit
				fi
			# --add6
			elif [[ $1 =~ ^\-\-(a6|add6)$ ]]; then
				# Get next in list
				shift
				# If that is a single IPv6 address
				if [[ $1 =~ ^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/128){0,1}$ ]]; then
					# Strip /128 from the IP
					THIS_IP=$( /usr/bin/echo $1 | /usr/bin/perl -p -e "s/\/128$//g" )
					# Add the IP to the block list
					addIPv6 $THIS_IP "single" "perm" "0"
					# And then exit
					exit
				# If that is an actual IPv6 range
				elif [[ $1 =~ ^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/[0-9]{1,2}){1}$ ]]; then
					addIPv6 $1 "range" "perm" "0"
					# And then exit
					exit
				# If it's neither
				else
					# Print error
					/usr/bin/echo "ERROR: '$1' does not appear to be an IPv6 address"
					# And exit
					exit
				fi
			# --del6
			elif [[ $1 =~ ^\-\-(d6|del6)$ ]]; then
				# Get next in list
				shift
				# If that is a single IPv6 address
				if [[ $1 =~ ^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/128){0,1}$ ]]; then
					# Strip /128 from the IP
					THIS_IP=$( /usr/bin/echo $1 | /usr/bin/perl -p -e "s/\/128$//g" )
					# Delete the IP from the block list
					delIPv6 $THIS_IP "single"
					# And then exit
					exit
				# If that is an IPv6 range
				elif [[ $1 =~ ^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/[0-9]{1,2}){1}$ ]]; then
					delIPv6 $1 "range"
					# And then exit
					exit
				# If it's neither
				else
					# Print error
					echo "ERROR: '$1' does not appear to be an IPv6 address"
					# And exit
					exit
				fi
			# --load/-l
			elif [[ $1 =~ ^\-((\-(load|reload|lp|rp))|(l))$ ]]; then
				# Make sure the default perm files exist
				/usr/bin/touch /opt/rh-firewall/rhfw_v4_custom-perm.txt
				/usr/bin/touch /opt/rh-firewall/rhfw_v6_custom-perm.txt
				# And load it in
				loadPerm
				# And then exit
				exit
			# --temp4/-t
			elif [[ $1 =~ ^\-((\-(temp|temp4|t4))|(t))$ ]]; then
				# Get IP
				shift
				THIS_IP=$1
				# Get time to block
				shift
				HOURS_TO_BLOCK=$1
				# Default to 24hours if not specified
				if [[ -z $HOURS_TO_BLOCK ]]; then
					HOURS_TO_BLOCK="24"
				fi
				# If HOURS_TO_BLOCK is not a number
				if [[ ! $HOURS_TO_BLOCK =~ ^([0-9]+)$ ]]; then
					# Print error
					echo "ERROR: '$HOURS_TO_BLOCK' does not appear to be a valid number"
					# And exit
					exit
				fi
				# If that is a single IPv4 address
				if [[ $THIS_IP =~ ^([0-9]{1,3}\.){3}([0-9]{1,3}){1}(\/32){0,1}$ ]]; then
					# Strip /32 from the IP is it exists
					THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\/32$//g" )
					# Add the IP to the block list
					addIPv4 $THIS_IP "single" "temp" $HOURS_TO_BLOCK
					# And then exit
					exit
				# If that is an actual IPv4 range
				elif [[ $THIS_IP =~ ^([0-9]{1,3}\.){3}([0-9]{1,3}){1}(\/[0-9]{1,2}){1}$ ]]; then
					addIPv4 $THIS_IP "range" "temp" $HOURS_TO_BLOCK
					# And then exit
					exit
				# If it's neither
				else
					# Print error
					echo "ERROR: '$THIS_IP' does not appear to be an IPv4 address"
					# And exit
					exit
				fi
			# --temp6
			elif [[ $1 =~ ^\-\-(t6|temp6)$ ]]; then
				# Get IP
				shift
				THIS_IP=$1
				# Get time to block
				shift
				HOURS_TO_BLOCK=$1
				# Default to 24hours if not specified
				if [[ -z $HOURS_TO_BLOCK ]]; then
					HOURS_TO_BLOCK="24"
				fi
				# If HOURS_TO_BLOCK is not a number
				if [[ ! $HOURS_TO_BLOCK =~ ^([0-9]+)$ ]]; then
					# Print error
					echo "ERROR: '$HOURS_TO_BLOCK' does not appear to be a valid number"
					# And exit
					exit
				fi
				# If that is a single IPv6 address
				if [[ $THIS_IP =~ ^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/128){0,1}$ ]]; then
					# Strip /32 from the IP is it exists
					THIS_IP=$( /usr/bin/echo $THIS_IP | /usr/bin/perl -p -e "s/\/128$//g" )
					# Add the IP to the block list
					addIPv6 $THIS_IP "single" "temp" $HOURS_TO_BLOCK
					# And then exit
					exit
				# If that is an actual IPv6 range
				elif [[ $THIS_IP =~ ^([a-f0-9:]{1,}:{1,}){1,}([a-f0-9]{1,}){1}(:){0,}(\/[0-9]{1,2}){1}$ ]]; then
					addIPv6 $THIS_IP "range" "temp" $HOURS_TO_BLOCK
					# And then exit
					exit
				# If it's neither
				else
					# Print error
					echo "ERROR: '$THIS_IP' does not appear to be an IPv6 address"
					# And exit
					exit
				fi
			# --refresh/-r
			elif [[ $1 =~ ^\-((\-(refresh|lt|rt))|(r))$ ]]; then
				# Make sure the default temp files exist
				/usr/bin/touch /opt/rh-firewall/rhfw_v4_custom-temp.csv
				/usr/bin/touch /opt/rh-firewall/rhfw_v6_custom-temp.csv
				# And load it in
				refreshTemp
				# And then exit
				exit
			# --install/-i, --update
			elif [[ $1 =~ ^\-((\-(install|update))|(i))$ ]]; then
				# Run installer/updater
				selfInstall
				# And then exit
				exit
			# --uninstall/-u
			elif [[ $1 =~ ^\-((\-(uninstall|remove))|(u))$ ]]; then
				# Run uninstaller
				selfUninstall
				# And then exit
				exit
			# --blocks/-b, --list
			elif [[ $1 =~ ^\-((\-(blocks|list))|(b))$ ]]; then
				# Get next in list
				shift
				# Run block lister
				listBlocks $1
				# And then exit
				exit
			# --switch/-s, --toggle
			elif [[ $1 =~ ^\-((\-(switch|toggle))|(s))$ ]]; then
				# Switch to `nftables`
				nftToggle
				# And then exit
				exit
			# Invalid option/argument/flag
			else
				# Print an error
				/usr/bin/echo "ERROR: '$1' is not a valid option"
				# And exit
				exit
			fi
			shift
		done
	# If there are none
	else
		# Print help
		printHelp
		# And then exit
		exit
	fi
}

# Entrypoint
main "$@"
