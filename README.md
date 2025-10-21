# rh-firewall

`rh-firewall` is a simple firewall built by Reclaim Hosting for our
Linux servers. It's a `bash` frontend for `nftables`/`iptables` that
blocks IPs. That's all it is, and all it does. It doesn't manage port
access, or do deep packet inspection, or anything like that. It just
blocks IPs. If you want something that does more, use something else;
`ufw` is a good choice if you don't want to deal directly with
`iptables`/`nftables`. But if you just need to block some IPs, then
`rh-firewall` will probably work for you. Because that's what it does.
And it works well enough for us in this capacity.

The choice to write this in `bash` as opposed to a _real_ language was
to ensure portability and limit dependencies; be warned, this `bash`
makes `perl` look like `python` at times. `rh-firewall` does still have
external dependencies, but they're all binaries that would usually be
installed on a standard Linux server anyways. We did only test on
AlmaLinux and Ubuntu, and while the paths to these binaries are the
same on both of those distros, they may be located elsewhere on others.
Since these are just `bash` scripts, you can easily change them.

`rh-firewall` uses `iptables` as it's backend by default, but it will
use `nftables` if its installed since `iptables` is old. _However_,
if `nftables` is instaled, but its rules are managed via `iptables-nft`,
then it will go back to using `iptables`. _HOWEVER_, if you want to make
it use `nftables` directly (without going through `iptables-nft`) then
you can run `rhfw --switch` to do so.

## Installing

```
git clone https://github.com/reclaimhosting/rh-firewall.git /opt/rh-firewall && \
ln -s /opt/rh-firewall/rh-firewall.service /etc/systemd/system/rh-firewall.service && \
systemctl daemon-reload && \
systemctl enable --now rh-firewall.service && \
ln -s /opt/rh-firewall/rhfw.sh /usr/local/bin/rhfw
```

## Updating

```
git -C /opt/rh-firewall pull
systemctl daemon-reload && \
systemctl restart rh-firewall.service
```

OR

```
rhfw --update
```

## Uninstalling

```
rhfw --uninstall
```

## Usage

IPs can be blocked in one of two ways: through the `rhfw` command
or through flat text files stored in `/opt/rh-firewall/defaults/`.

Keep in mind that overlapping IPs/IP ranges may end up getting merged,
especially when `rh-firewall` is using `nftables` as a back end since
sets are created with the `auto-merge` flag. This is for simplicity's
sake, but may cause confusion when trying to add/remove blocked IPs.
Remember: when in doubt, list them out with `rhfw --list`.

### /opt/rh-firewall/defaults/

The default lists are flat text files of IP addresses (including ranges,
but one per line) that are to be permanently blocked. This method is
useful for distributing lists of known bad IPs to multiple servers in
your fleet. The lists must be named in the following way (for lists of
IPv4s and IPv6s respectivley):
- rhfw_v4_default_*.txt
- rhfw_v6_default_*.txt

Adding/removing lists may be done dynamically, but you'll need to
either wait for the service to re-load these default lists or
restart it manually with a `systemctl restart rh-firewall.service`.

The actual names of the sets get _compressed_ when being loaded in, and
can't be longer than 16 chars (due to limits of `nftables`), so they
end up looking like the following; keep this in mind when naming the
files these sets are loaded from, as there's not great collision 
handling (READ: no collision handling at all).
- rhfw4d*
- rhfw6d*

So that last bit of the name that actually describes the list can't be
larger than 10 chars, and those 10 chars have to be unique from any
other list of IPs in the directory.

### rhfw (rhfw.sh)

The `rhfw` command is (assuming the above installation instructions
were followed and the symlink was created) just a symlink to the script
at `/opt/rh-firewall/rhfw.sh`. So call the script directly or use the
symlinked command; it's the same thing either way.

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

## Possible Integrations

### Wazuh

Reclaim Hosting uses Wazuh as a SIEM and has developed custom scripts to
integrate Wazuh's active response with `rh-firewall` to block IPs that
trigger certain rules. While these scripts are kept internal, the best
way we have found to do this is by creating a new defaults script
(something like `rhfw_v4_default_wazuhar.txt`) and having these active
response scripts add/remove IPs from this list as per the rules of the
SIEM.

### Ansible

Reclaim Hosting uses Ansible to manage our fleet of servers, and as
all components of `rh-firewall` are written in `bash`, both distribution
of default block lists and adding/removing IPs is made easier with
Ansible. For example, something like the following could be used to
block an IP across all servers in a fleet with Ansible:
	```
	ansible all -m shell -a "bash /opt/rh-firewall/rhfw.sh --add4 192.168.5.3"
	```

### Other

This firewall is just a collection of shell scripts and flat text files.
If whatever you want to integrate with it is capable of executing scripts
or writing to a text file, you can integrate it with `rh-firewall`.

## Dependencies

Here's a list of all of the binaries (and what paths they're called at)
used by `rh-firewall`. Most of them are standard on most linux distros,
but maybe they're installed somewhere besides the expected path.

- /usr/bin/awk
- /usr/bin/bash
- /usr/bin/cat
- /usr/bin/chmod
- /usr/bin/chown
- /usr/bin/cut
- /usr/bin/date
- /usr/bin/echo
- /usr/bin/env
- /usr/bin/git
- /usr/bin/grep
- /usr/bin/head
- /usr/bin/ln
- /usr/bin/ls
- /usr/bin/perl
- /usr/bin/rm
- /usr/bin/sleep
- /usr/bin/sort
- /usr/bin/systemctl
- /usr/bin/touch
- /usr/bin/uniq
- /usr/bin/unlink
- /usr/bin/which
- /usr/sbin/ip6tables
- /usr/sbin/ipset
- /usr/sbin/iptables
- /usr/sbin/nft
