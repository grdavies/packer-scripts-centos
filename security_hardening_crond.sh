#!/usr/bin/env bash
##############################################################################
## Hardening for crond
##############################################################################
## Files modified
##
## /etc/anacrontab
## /etc/crontab
## /etc/at.deny
## /etc/cron.deny
## /etc/cron.d
## /etc/cron.hourly
## /etc/cron.daily
## /etc/cron.weekly
## /etc/cron.monthly
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-crond.cfg
##
##############################################################################
## Notes
##
## Securing cron, at, and anacron
##
## Modifying the permissions on these file may result in
## a warning on "Verify and Correct File Permissions with RPM"
## evaulation in oscap.  Verify which files are causing this
## warning with: rpm -Va | grep ^M
##
##############################################################################

#timestamp
echo "** security_hardening_crond.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y at \
                cronie \
                cronie-anacron \
                crontabs

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}" ]; then mkdir -p ${BACKUPDIR}; fi

/bin/cp -fpd /etc/anacrontab ${BACKUPDIR}/anacrontab-DEFAULT
/bin/cp -fpd /etc/crontab    ${BACKUPDIR}/crontab-DEFAULT
/bin/cp -fpd /etc/at.deny    ${BACKUPDIR}/at.deny-DEFAULT
/bin/cp -fpd /etc/cron.deny  ${BACKUPDIR}/cron.deny-DEFAULT

/bin/cp -Rfpd /etc/cron.d      ${BACKUPDIR}/cron.d-DEFAULT
/bin/cp -Rfpd /etc/cron.hourly ${BACKUPDIR}/cron.hourly-DEFAULT
/bin/cp -Rfpd /etc/cron.daily  ${BACKUPDIR}/cron.daily-DEFAULT
/bin/cp -Rfpd /etc/cron.weekly ${BACKUPDIR}/cron.weekly-DEFAULT
/bin/cp -Rfpd /etc/cron.monthly ${BACKUPDIR}/cron.monthly-DEFAULT

################################################
## DEPLOY NEW FILES
## No new files, just removing or changing
## permissions on old files so that only root
## and selected users can install cron events.
################################################

### CIS 6.1.3 Set User/Group Owner and Permission on /etc/anacrontab

chown root:root /etc/anacrontab
chmod 600 /etc/anacrontab

### CIS 6.1.4 Set User/Group Owner and Permission on /etc/crontab

chown root:root /etc/crontab
chmod 600 /etc/crontab

### CIS 6.1.5 Set User/Group Owner and Permission on /etc/cron.hourly

chown root:root /etc/cron.hourly
chmod 700 /etc/cron.hourly

### CIS 6.1.6 Set User/Group Owner and Permission on /etc/cron.daily

chown root:root /etc/cron.daily
chmod 700 /etc/cron.daily

### CIS 6.1.7 Set User/Group Owner and Permission on /etc/cron.weekly

chown root:root /etc/cron.weekly
chmod 700 /etc/cron.weekly

### CIS 6.1.8 Set User/Group Owner and Permission on /etc/cron.monthly

chown root:root /etc/cron.monthly
chmod 700 /etc/cron.monthly

### CIS 6.1.9 Set User/Group Owner and Permission on /etc/cron.d

chown root:root /etc/cron.d
chmod 700 /etc/cron.d

### CIS 6.1.10 Restrict at Daemon
### CIS 6.1.11 Restrict at/cron to Authorized Users
### root can always create cron and at jobs for any user
### Only those in cron.allow and at.allow create new cron
### and at jobs for themselves.

/bin/rm /etc/cron.deny
/bin/rm /etc/at.deny
touch /etc/cron.allow
touch /etc/at.allow
chown root:root /etc/cron.allow
chown root:root /etc/at.allow
chmod 600 /etc/cron.allow
chmod 600 /etc/at.allow

####################
## TURN ON SERVICE
####################

### CIS 6.1.1 Enable anacron Daemon
### CIS 6.1.2 Enable crond Daemon
systemctl enable crond.service

systemctl disable atd.service

#timestamp
echo "** security_hardening_crond.sh COMPLETE" $(date +%F-%H%M-%S)
