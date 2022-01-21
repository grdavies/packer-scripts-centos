#!/usr/bin/env bash
##############################################################################
## Hardening for Repos
##############################################################################
## Files modified
##
## /boot/grub2/grub.cfg
## /etc/grub.d/*
## /etc/default/grub
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-grub.cfg
##
##############################################################################
## Notes
##
##############################################################################

#timestamp
echo "** security_hardening_grub.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y grub2 \
                grub2-tools

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}" ]; then mkdir -p ${BACKUPDIR}; fi

/bin/cp -fpd /boot/grub2/grub.cfg ${BACKUPDIR}/grub.cfg-DEFAULT
/bin/cp -fpd /etc/default/grub    ${BACKUPDIR}/grub-DEFAULT

/bin/cp -Rfpd /etc/grub.d ${BACKUPDIR}/


####################
## WRITE NEW FILES
####################


cat > ${BACKUPDIR}/postboot-grub.txt << 'EOF'

### CIS 1.4.1 Ensure SELinux is not disabled in /boot/grub2/grub.cfg ( Level 2 )
# must not have enforcing=0 or selinux=0

### CIS 1.5.1 Set User/Group Owner on /boot/grub2/grub.cfg
# must be root:root

### CIS 1.5.2 Set Permissions on /boot/grub2/grub.cfg
# must be 600

### CIS 1.5.3 Set Boot Loader Password
# For each user, create hash of password with
# grub2-mkpasswd-pbkdf2
# add to /etc/grub.d/00_header:
# set superusers="<list_of_users>"
# password_pbkdf2 <user> <hash>
# Then run:
# grub2-mkconfig -o /boot/grub2/grub.cfg

### CIS 5.2.3 Enable Auditing for Processes That Start Prior to auditd ( Level 2 )
# to  /etc/default/grub add:
# GRUB_CMDLINE_LINUX="audit=1"
# Then run:
#  grub2-mkconfig -o /boot/grub2/grub.cfg

EOF

#####################
## DEPLOY NEW FILES
#####################

/bin/chown root:root /boot/grub2/grub.cfg
/bin/chmod       600 /boot/grub2/grub.cfg

#timestamp
echo "** security_hardening_grub.sh COMPLETE" $(date +%F-%H%M-%S)
