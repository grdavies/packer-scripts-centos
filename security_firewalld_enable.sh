#!/usr/bin/env bash
##############################################################################
## Enable firewalld
##############################################################################
## Files modified
##
## /etc/firewalld/firewalld.conf
##
############################################################################
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-firewalld.cfg
##
##############################################################################
## Notes
##
##############################################################################

# Ensure firewalld is installed
yum install -y firewalld

#timestamp
echo "** c7-firewalld START" $(date +%F-%H%M-%S)

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening/firewalld

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}" ]; then mkdir -p ${BACKUPDIR}; fi

/bin/cp -fpd /etc/firewalld/firewalld.conf ${BACKUPDIR}/firewalld.conf-DEFAULT

####################
## WRITE NEW FILES
####################

# Here Files
# http://tldp.org/LDP/abs/html/here-docs.html
# Note: No parameter substitution when the "limit string" is quoted or escaped.

cat > ${BACKUPDIR}/firewalld.conf << 'EOF'
# firewalld config file

# default zone
# The default zone used if an empty zone string is used.
# Default: public
DefaultZone=drop

# Minimal mark
# Marks up to this minimum are free for use for example in the direct
# interface. If more free marks are needed, increase the minimum
# Default: 100
MinimalMark=100

# Clean up on exit
# If set to no or false the firewall configuration will not get cleaned up
# on exit or stop of firewalld
# Default: yes
CleanupOnExit=yes

# Lockdown
# If set to enabled, firewall changes with the D-Bus interface will be limited
# to applications that are listed in the lockdown whitelist.
# The lockdown whitelist file is lockdown-whitelist.xml
# Default: no
Lockdown=no

# IPv6_rpfilter
# Performs a reverse path filter test on a packet for IPv6. If a reply to the
# packet would be sent via the same interface that the packet arrived on, the
# packet will match and be accepted, otherwise dropped.
# The rp_filter for IPv4 is controlled using sysctl.
# Default: yes
IPv6_rpfilter=yes
EOF

#####################
## DEPLOY NEW FILES
#####################

#/bin/cp -f ${BACKUPDIR}/firewalld.conf /etc/firewalld/firewalld.conf
#/bin/chown root:root /etc/firewalld/firewalld.conf
#/bin/chmod       640 /etc/firewalld/firewalld.conf

####################
## TURN ON SERVICE
####################

systemctl enable firewalld

####################
## START SERVICE
####################

systemctl start firewalld

#timestamp
echo "** c7-firewalld COMPLETE" $(date +%F-%H%M-%S)
