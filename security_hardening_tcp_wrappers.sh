#!/usr/bin/env bash
##############################################################################
## Hardening for TCP wrappers
##############################################################################
## Files modified
##
## /etc/hosts.allow
## /etc/hosts.deny
##
##############################################################################
## License
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License along
## with this program; if not, write to the Free Software Foundation, Inc.,
## 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
##############################################################################
## References
##
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-tcp_wrappers.cfg
##
##############################################################################
## Notes
## Not all services use tcp_wrappers.
## ldd <binary> | grep libwrap will show if its used.
## Firewall rules are more reliable. tcp_wrappers is expected to be phased out.
##
##############################################################################

#timestamp
echo "** security_hardening_tcp_wrappers.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y tcp_wrappers

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}" ]; then mkdir -p ${BACKUPDIR}; fi

/bin/cp -fpd /etc/hosts.allow ${BACKUPDIR}/hosts.allow-DEFAULT
/bin/cp -fpd /etc/hosts.deny  ${BACKUPDIR}/hosts.deny-DEFAULT

####################
## WRITE NEW FILES
####################

################
## hosts.allow
################

cat > ${BACKUPDIR}/hosts.allow << 'EOFALLOW'
#
# hosts.allow	This file contains access rules which are used to
#		allow or deny connections to network services that
#		either use the tcp_wrappers library or that have been
#		started through a tcp_wrappers-enabled xinetd.
#
#		See 'man 5 hosts_options' and 'man 5 hosts_access'
#		for information on rule syntax.
#		See 'man tcpd' for information on tcp_wrappers
#

# Allow allow services to localhost
ALL: 127.0.0.1 LOCAL localhost

# Allow ssh from all ip addresses
sshd: ALL

# Allow ssh from only 192.168.0.0/16
#sshd: 192.168.

EOFALLOW

################
## hosts.deny
################

cat > ${BACKUPDIR}/hosts.deny << 'EOFDENY'
#
# hosts.deny	This file contains access rules which are used to
#		deny connections to network services that either use
#		the tcp_wrappers library or that have been
#		started through a tcp_wrappers-enabled xinetd.
#
#		The rules in this file can also be set up in
#		/etc/hosts.allow with a 'deny' option instead.
#
#		See 'man 5 hosts_options' and 'man 5 hosts_access'
#		for information on rule syntax.
#		See 'man tcpd' for information on tcp_wrappers
#

# Deny all services from all ip addresses by default
ALL: ALL

#spawn command upon deny, in this case send email
#ALL: ALL : spawn (/bin/echo -e \`/bin/date\` "\n%c attempted connection to %s and was denied"\ | /bin/mail -s "%c denied to %s" admin@doman.com ) &

EOFDENY

#####################
## DEPLOY NEW FILES
#####################

/bin/cp -f ${BACKUPDIR}/hosts.allow /etc/hosts.allow
chown root:root /etc/hosts.allow
chmod       644 /etc/hosts.allow

/bin/cp -f ${BACKUPDIR}/hosts.deny /etc/hosts.deny
chown root:root /etc/hosts.deny
chmod       644 /etc/hosts.deny

#timestamp
echo "** security_hardening_tcp_wrappers.sh COMPLETE" $(date +%F-%H%M-%S)
