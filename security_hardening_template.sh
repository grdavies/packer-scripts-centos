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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-repos.cfg
##
##############################################################################
## Notes
##
##############################################################################

#timestamp
echo "** security_hardening_template.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y centos-release \
                centos-release-scl


#timestamp
echo "** security_hardening_template.sh COMPLETE" $(date +%F-%H%M-%S)
