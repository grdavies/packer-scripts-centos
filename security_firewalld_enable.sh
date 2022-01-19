#!/usr/bin/env bash
##############################################################################
## Enable firewalld
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-firewalld.cfg
##
##############################################################################
## Notes
##
##############################################################################

#timestamp
echo "** security_firewalld_enable.sh START" $(date +%F-%H%M-%S)

#################
## SET BASH ERREXIT OPTION
#################
set -o errexit

####################
## INSTALL FIREWALLD
####################

yum install -y firewalld

####################
## TURN ON SERVICE
####################

systemctl enable firewalld

####################
## START SERVICE
####################

systemctl start firewalld

#timestamp
echo "** security_firewalld_enable.sh COMPLETE" $(date +%F-%H%M-%S)
