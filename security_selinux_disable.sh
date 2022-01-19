#!/usr/bin/env bash
##############################################################################
## Disable selinux
##############################################################################
## Files modified
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
##
##
##############################################################################
## Notes
##
##############################################################################

#timestamp
echo "** security_selinux_disable.sh START" $(date +%F-%H%M-%S)

#################
## SET BASH ERREXIT OPTION
#################
set -o errexit

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}" ]; then mkdir -p ${BACKUPDIR}; fi

/bin/cp -fpd /etc/selinux/config ${BACKUPDIR}/selinux_config-DEFAULT

#################
## WRITE NEW FILES
#################

cat > ${BACKUPDIR}/selinux_config << 'EOFSELINUX'

# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
EOFSELINUX

#####################
## DEPLOY NEW FILES
#####################
/bin/cp -f ${BACKUPDIR}/selinux_config /etc/selinux/config
/bin/chown root:root /etc/selinux/config
/bin/chmod 0644      /etc/selinux/config

echo "** security_selinux_disable.sh COMPLETE" $(date +%F-%H%M-%S)
