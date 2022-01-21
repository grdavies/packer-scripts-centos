#!/usr/bin/env bash
##############################################################################
## Hardening for aide
##############################################################################
## Files modified
##
## /etc/yum.repos.d/CentOS-Base.repo
## /etc/yum.repos.d/CentOS-CR.repo
## /etc/yum.repos.d/CentOS-SCLo-scl.repo
## /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
## /etc/yum.repos.d/epel.repo
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-aide.cfg
##
##############################################################################
## Notes
##
## https://github.com/OpenSCAP/scap-security-guide/blob/master/RHEL/6/input/remediations/bash/disable_prelink.sh
##
## OpenSCAP appears to never detect that prelink is turned off in Centos
## OpenSCAP does not detect the aide-check cron jobs in this file
##
##############################################################################

#timestamp
echo "** security_hardening_aide.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y coreutils \
                crontabs \
                aide \
                prelink

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}" ]; then mkdir -p ${BACKUPDIR}; fi

/bin/cp -fpd /etc/aide.conf ${BACKUPDIR}/aide.conf-DEFAULT
/bin/cp -fpd /etc/aide.conf ${BACKUPDIR}/aide.conf
/bin/cp -fpd /etc/sysconfig/prelink ${BACKUPDIR}/prelink-DEFAULT
/bin/cp -fpd /etc/sysconfig/prelink ${BACKUPDIR}/prelink
/bin/cp -fpd /etc/crontab ${BACKUPDIR}/crontab-DEFAULT

####################
## WRITE NEW FILES
####################

##########################
## /etc/aide.conf
## CCE-80375-9 Configure AIDE to Verify Access Control Lists (ACLs) (The default)
## CCE-80376-7 Configure AIDE to Verify Extended Attributes ( The default )
## CCE-80377-5 Configure AIDE to Use FIPS 140-2 for Validating Hashes
##########################

sed -i 's@^NORMAL = sha256@### CCE-80377-5 Configure AIDE to Use FIPS 140-2 for Validating Hashes\nNORMAL = FIPSR+sha512@g' ${BACKUPDIR}/aide.conf

##########################
## /etc/sysconfig/prelink
##########################

## CCE-27078-5 Disable Prelinking

if grep -q ^PRELINKING ${BACKUPDIR}/prelink
then
  sed -i 's@PRELINKING.*@###  CCE-27078-5 Disable Prelinking\nPRELINKING=no@g' ${BACKUPDIR}/prelink
else
  echo -e "\n###  CCE-27078-5 Disable Prelinking" >> ${BACKUPDIR}/prelink
  echo "PRELINKING=no" >> ${BACKUPDIR}/prelink
fi

############################
## /etc/cron.d/aide-check
############################

cat > ${BACKUPDIR}/aide-check << 'EOFCRON'
## CCE-26952-2 Configure Periodic Execution of AIDE
## CCE-80374-2 Configure Notification of Post-AIDE Scan Details
05 4 * * * root /usr/sbin/aide --check | /bin/mail -s "$(hostname) - AIDE Integrity Check" root@localhost
EOFCRON

#############################
## postboot-aide-check.txt
#############################

cat > ${BACKUPDIR}/postboot-aide-check.txt<< 'EOFCHECK'
## CCE-26952-2 Configure Periodic Execution of AIDE

# alternative ways to periodically execute aide
# pick just one

# the one used by default in this script
# in /etc/cron.d
echo "05 4 * * * root /usr/sbin/aide --check | /bin/mail -s "$(hostname) - AIDE Integrity Check" root@localhost" >> /etc/cron.d/aide-check

# the one used in the openscap remediation scripts
# in /etc/crontab
echo "05 4 * * * root /usr/sbin/aide --check | /bin/mail -s "$(hostname) - AIDE Integrity Check" root@localhost" >> /etc/crontab

# in root's crontab: crontab
05 4 * * * /usr/sbin/aide --check | /bin/mail -s "$(hostname) - AIDE Integrity Check" root@localhost

EOFCHECK

#############################
## postboot-aide-update.txt
#############################

cat > ${BACKUPDIR}/postboot-aide-update.txt << 'EOFUP'

umask 0077
cd /var/lib/aide/
aide --update > aide-$(date +%F).log 2> aide-$(date +%F).log &
/bin/cp -fpd aide.db.new.gz aide.db.gz
/bin/cp -ipd aide.db.new.gz aide-$(date +%F).db.gz
chmod 400 aide-$(date +%F).db.gz
sha256sum aide-$(date +%F).db.gz >> aide.sha256.txt

#off server backup of /var/lib/aide/*

EOFUP


#####################
## DEPLOY NEW FILES
#####################

/bin/cp -f ${BACKUPDIR}/aide.conf /etc/aide.conf
/bin/chown root:root /etc/aide.conf
/bin/chmod       600 /etc/aide.conf

/bin/cp -f ${BACKUPDIR}/prelink /etc/sysconfig/prelink
/bin/chown root:root /etc/sysconfig/prelink
/bin/chmod       644 /etc/sysconfig/prelink

/bin/cp -f ${BACKUPDIR}/aide-check /etc/cron.d/aide-check
/bin/chown root:root /etc/cron.d/aide-check
/bin/chmod       600 /etc/cron.d/aide-check


#############################################
## CCE-27220-3 Build and Test AIDE Database
#############################################
#  Running this will noticably increase the time to install
#  the operating system.
#############################################

/usr/sbin/aide --init

## MOVE DATABASE

/bin/cp -fpd /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
/bin/chown root:root /var/lib/aide/aide.db.gz
/bin/chmod       600 /var/lib/aide/aide.db.gz
/bin/cp -ipd /var/lib/aide/aide.db.gz /var/lib/aide/aide-$(date +%F).db.gz
/bin/chmod       400 /var/lib/aide/aide-$(date +%F).db.gz
/bin/sha256sum /var/lib/aide/aide-$(date +%F).db.gz >> /var/lib/aide/aide.sha256.txt

## CHECK DATABASE

#/usr/sbin/aide --check

####################
## TURN ON SERVICE
####################

systemctl enable  crond

#timestamp
echo "** security_hardening_aide.sh COMPLETE" $(date +%F-%H%M-%S)
