#!/usr/bin/env bash
##############################################################################
## Hardening for etckeeper
##############################################################################
## Files modified
##
## /etc/etckeeper
## /etc/.git
## /etc/.gitignore
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-repos.cfg
##
##############################################################################
## Notes
##
##############################################################################

#timestamp
echo "** security_hardening_etckeeper.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y epel-release \
                etckeeper

##############################
## CREATE etckeeper GIT REPO
##############################

cd /etc
/usr/bin/etckeeper init

git config --global user.email "root@localhost"
git config --global user.name  "etckeeper"

##################################
## DO NOT BACKUP PASSWORD HASHES
##################################

cd /etc

git rm --cached shadow*
echo shadow* >> .gitignore

git rm --cached gshadow*
echo gshadow* >> .gitignore

git rm --cached security/opasswd*
echo security/opasswd* >> .gitignore

git commit -a -m "don't track shadow, shadow~, gshadow, gshadow~, opasswd"

#timestamp
echo "** security_hardening_etckeeper.sh COMPLETE" $(date +%F-%H%M-%S)
