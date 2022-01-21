#!/usr/bin/env bash
##############################################################################
## Hardening for fstab
##############################################################################
## Files modified
##
## /etc/fstab
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-fstab.cfg
##
##############################################################################
## Notes
##
##############################################################################

#timestamp
echo "** security_hardening_fstab.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y setup

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}" ]; then mkdir -p ${BACKUPDIR}; fi

/bin/cp -fpd /etc/fstab ${BACKUPDIR}/fstab-DEFAULT
/bin/cp -fpd /etc/fstab ${BACKUPDIR}/fstab

####################
## WRITE NEW FILES
####################

echo "#"                                                       >> ${BACKUPDIR}/fstab
echo "### CCE-80155-5 Bind Mount /var/tmp To /tmp"             >> ${BACKUPDIR}/fstab
echo "/tmp   /var/tmp  none   rw,nodev,nosuid,noexec,bind 0 0" >> ${BACKUPDIR}/fstab
echo "### CCE-80152-2 CCE-80154-8 CCE-80153-0"                 >> ${BACKUPDIR}/fstab
echo "### Add nodev, nosuid, noexec to /dev/shm"               >> ${BACKUPDIR}/fstab
echo "shmfs  /dev/shm  tmpfs  nodev,nosuid,noexec         0 0" >> ${BACKUPDIR}/fstab

#####################
## DEPLOY NEW FILES
#####################

/bin/cp -f ${BACKUPDIR}/fstab /etc/fstab
/bin/chown root:root /etc/fstab
/bin/chmod 644       /etc/fstab

#timestamp
echo "** security_hardening_fstab.sh COMPLETE" $(date +%F-%H%M-%S)
