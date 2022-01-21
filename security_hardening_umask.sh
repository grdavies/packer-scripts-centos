#!/usr/bin/env bash
##############################################################################
## Hardening for Repos
##############################################################################
## Files modified
##
## /etc/init.d/functions
## /etc/sysconfig/init
## /etc/bashrc
## /etc/profile.d/umask.sh
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-umask.cfg
##
##############################################################################
## Notes
##
##############################################################################

#timestamp
echo "** security_hardening_umask.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y initscripts \
                setup

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening/umask

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}/init.d" ]; then mkdir -p ${BACKUPDIR}/init.d; fi

/bin/cp -fpd /etc/init.d/functions ${BACKUPDIR}/init.d/functions-DEFAULT
/bin/cp -fpd /etc/init.d/functions ${BACKUPDIR}/init.d/functions

mkdir -p ${BACKUPDIR}/sysconfig

/bin/cp -fpd /etc/sysconfig/init ${BACKUPDIR}/sysconfig/init-DEFAULT
/bin/cp -fpd /etc/sysconfig/init ${BACKUPDIR}/sysconfig/init

/bin/cp -fpd /etc/bashrc  ${BACKUPDIR}/bashrc-DEFAULT
/bin/cp -fpd /etc/bashrc  ${BACKUPDIR}/bashrc

/bin/cp -fpd /etc/csh.cshrc  ${BACKUPDIR}/csh.cshrc-DEFAULT
/bin/cp -fpd /etc/csh.cshrc  ${BACKUPDIR}/csh.cshrc

/bin/cp -fpd /etc/profile  ${BACKUPDIR}/profile-DEFAULT
/bin/cp -fpd /etc/profile  ${BACKUPDIR}/profile

mkdir -p ${BACKUPDIR}/profile.d

####################
## WRITE NEW FILES
####################

###############################
## /etc/init.d/functions
###############################
## CCE-27068-6 Set Daemon Umask

sed -i "s/umask.*/umask 027/g" ${BACKUPDIR}/init.d/functions

###############################
## /etc/sysconfig/init
###############################

echo "### CIS 3.1 Set Daemon umask" >> ${BACKUPDIR}/sysconfig/init
echo "umask 027" >> ${BACKUPDIR}/sysconfig/init

###############################
## /etc/bashrc
###############################

echo "" >> ${BACKUPDIR}/bashrc
echo "# CIS 5.4.4 Ensure default user umask is 027 or more restrictive" >> ${BACKUPDIR}/bashrc
echo "umask 027" >> ${BACKUPDIR}/bashrc
echo "" >> ${BACKUPDIR}/bashrc
echo "# Users can set their umask in their own ~/.bashrc" >> ${BACKUPDIR}/bashrc

###############################
## /etc/csh.cshrc
###############################
## CCE-27034-8 Ensure the Default C Shell Umask is Set Correctly

sed -i "s/umask.*/umask 027/g" ${BACKUPDIR}/csh.cshrc
echo "# Users can set their umask in their own ~/.cshrc" >> ${BACKUPDIR}/csh.cshrc

###############################
## /etc/profile
###############################
## CCE-26669-2 Ensure the Default Umask is Set Correctly in /etc/profile

sed -i "s/umask.*/umask 027/g" ${BACKUPDIR}/profile

###############################
## /etc/profile.d/umask.sh
###############################

cat > ${BACKUPDIR}/profile.d/umask.sh << 'EOF'
# CIS 5.4.4 Ensure default user umask is 027 or more restrictive
umask 027
EOF

#####################
## DEPLOY NEW FILES
#####################

/bin/cp -f ${BACKUPDIR}/init.d/functions /etc/init.d/functions
/bin/chown root:root /etc/init.d/functions
/bin/chmod       644 /etc/init.d/functions

/bin/cp -f ${BACKUPDIR}/sysconfig/init /etc/sysconfig/init
/bin/chown root:root /etc/sysconfig/init
/bin/chmod       644 /etc/sysconfig/init

/bin/cp -f ${BACKUPDIR}/bashrc /etc/bashrc
/bin/chown root:root /etc/bashrc
/bin/chmod       644 /etc/bashrc

/bin/cp -f ${BACKUPDIR}/csh.cshrc /etc/csh.cshrc
/bin/chown root:root /etc/csh.cshrc
/bin/chmod       644 /etc/csh.cshrc

/bin/cp -f ${BACKUPDIR}/profile /etc/profile
/bin/chown root:root /etc/profile
/bin/chmod       644 /etc/profile

/bin/cp -f ${BACKUPDIR}/profile.d/umask.sh /etc/profile.d/umask.sh
/bin/chown root:root /etc/profile.d/umask.sh
/bin/chmod       644 /etc/profile.d/umask.sh

#timestamp
echo "** security_hardening_umask.sh COMPLETE" $(date +%F-%H%M-%S)
