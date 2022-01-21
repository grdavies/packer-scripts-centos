#!/usr/bin/env bash
##############################################################################
## Hardening for Repos
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-securetty.cfg
##
##############################################################################
## Notes
##
## The /etc/securetty is used by pam to controls devices the root user
## is allowed to login to.
##
## Device and console names
## https://www.ibm.com/support/knowledgecenter/linuxonibm/com.ibm.linux.z.lgdd/lgdd_r_console_sum.html
##
##############################################################################

#timestamp
echo "** security_hardening_secure_tty.sh START" $(date +%F-%H%M-%S)

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

/bin/cp -fpd /etc/securetty ${BACKUPDIR}/securetty-DEFAULT

####################
## WRITE NEW FILES
####################

###################
## /etc/securetty
###################

cat > ${BACKUPDIR}/securetty << 'EOF'
# This file must exist, even if empty, else
# all devices are allowed.

# CCE-27294-8 Direct root Logins Not Allowed
# If no direct root logins are required, remove
# all entries from this file.

console

# CCE-27318-5 Restrict Virtual Console Root Logins
#vc/1
#vc/2
#vc/3
#vc/4
#vc/5
#vc/6
#vc/7
#vc/8
#vc/9
#vc/10
#vc/11

tty1
tty2
tty3
tty4
tty5
tty6
tty7
tty8
tty9
tty10
tty11

# CCE-27268-2 Restrict Serial Port Root Logins
#ttyS0

# VT220 terminal device driver
ttysclp0
# SCLP line-mode terminal device driver
sclp_line0
# 3270 terminal device driver
3270/tty1

# paravirtualized virtual-console provided by KVM
hvc0
hvc1
hvc2
hvc3
hvc4
hvc5
hvc6
hvc7
hvsi0
hvsi1
hvsi2
xvc0

EOF

#####################
## DEPLOY NEW FILES
#####################

/bin/cp -f ${BACKUPDIR}/securetty /etc/securetty
/bin/chown root:root /etc/securetty
/bin/chmod       600 /etc/securetty

#timestamp
echo "** security_hardening_secure_tty.sh COMPLETE" $(date +%F-%H%M-%S)
