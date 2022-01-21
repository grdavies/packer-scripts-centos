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
## Signed Repository Metadata is now Available for CentOS 6 and 7 for the Updates Repo
## First use of the repository will require confirmation of the signing key
## http://seven.centos.org/2015/05/signed-repository-metadata-is-now-available-for-centos-6-and-7-for-the-updates-repo/
##
##############################################################################

#timestamp
echo "** security_hardening_repos.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y centos-release \
                centos-release-scl \
                centos-release-scl-rh \
                epel-release \
                yum-plugin-fastestmirror \
                yum-plugin-priorities \
                yum-utils \
                yum-plugin-verify \
                yum-plugin-list-data deltarpm

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}/yum.repos.d" ]; then mkdir -p ${BACKUPDIR}/yum.repos.d; fi

/bin/cp -fpd /etc/yum.conf ${BACKUPDIR}/yum.conf-DEFAULT

/bin/cp -fpd /etc/yum.repos.d/CentOS-Base.repo ${BACKUPDIR}/yum.repos.d/CentOS-Base.repo-DEFAULT
/bin/cp -fpd /etc/yum.repos.d/CentOS-CR.repo       ${BACKUPDIR}/yum.repos.d/CentOS-CR.repo-DEFAULT
/bin/cp -fpd /etc/yum.repos.d/CentOS-SCLo-scl.repo   ${BACKUPDIR}/yum.repos.d/CentOS-SCLo-scl.repo-DEFAULT
/bin/cp -fpd /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo ${BACKUPDIR}/yum.repos.d/CentOS-SCLo-scl-rh.repo-DEFAULT
/bin/cp -fpd /etc/yum.repos.d/epel.repo               ${BACKUPDIR}/yum.repos.d/epel.repo-DEFAULT

#########################################################################
## WRITE NEW /etc/yum.conf FILE
#########################################################################

cat >> ${BACKUPDIR}/yum.conf << 'EOFCONF'
[main]
cachedir=/var/cache/yum/$basearch/$releasever
keepcache=0
debuglevel=2
logfile=/var/log/yum.log
exactarch=1
obsoletes=1
plugins=1
installonly_limit=5
bugtracker_url=http://bugs.centos.org/set_project.php?project_id=23&ref=http://bugs.centos.org/bug_report_page.php?category=yum
distroverpkg=centos-release

## CCE-26989-4 Ensure gpgcheck Enabled In Main Yum Configuration
gpgcheck=1

## CCE-80346-0 Ensure YUM Removes Previous Package Versions
clean_requirements_on_remove=1

## CCE-80347-8 Ensure gpgcheck Enabled for Local Packages
localpkg_gpgcheck=1

## CCE-80348-6 Ensure gpgcheck Enabled for Repository Metadata
## Note: not all repositories have this enabled
repo_gpgcheck=1

#  This is the default, if you make this bigger yum won't see if the metadata
# is newer on the remote and so you'll "gain" the bandwidth of not having to
# download the new metadata and "pay" for it by yum not having correct
# information.
#  It is esp. important, to have correct metadata, for distributions like
# Fedora which don't keep old packages around. If you don't like this checking
# interupting your command line usage, it's much better to have something
# manually check the metadata once an hour (yum-updatesd will do this).
# metadata_expire=90m

# PUT YOUR REPOS HERE OR IN separate files named file.repo
# in /etc/yum.repos.d

EOFCONF

#########################################################################
## WRITE NEW /etc/yum.repos.d/CentOS-Base.repo FILE
## CCE-26876-3 Ensure gpgcheck Enabled For All Yum Package Repositories
#########################################################################

cat >> ${BACKUPDIR}/yum.repos.d/CentOS-Base.repo << 'EOFBASE'
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-$releasever - Base
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
#baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
gpgcheck=1
repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
#protect=1
#priority=1

#released updates
[updates]
name=CentOS-$releasever - Updates
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates&infra=$infra
#baseurl=http://mirror.centos.org/centos/$releasever/updates/$basearch/
gpgcheck=1
repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
#protect=1
#priority=1

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras&infra=$infra
#baseurl=http://mirror.centos.org/centos/$releasever/extras/$basearch/
gpgcheck=1
repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
#protect=0
#priority=1

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus&infra=$infra
#baseurl=http://mirror.centos.org/centos/$releasever/centosplus/$basearch/
gpgcheck=1
repo_gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
#protect=0
#priority=2

EOFBASE

###################
## CentOS-CR.repo
###################

cat >> ${BACKUPDIR}/yum.repos.d/CentOS-CR.repo << 'EOFCR'
# CentOS-CR.repo
#
# The Continuous Release ( CR )  repository contains rpms that are due in the next
# release for a specific CentOS Version ( eg. next release in CentOS-7 ); these rpms
# are far less tested, with no integration checking or update path testing having
# taken place. They are still built from the upstream sources, but might not map
# to an exact upstream distro release.
#
# These packages are made available soon after they are built, for people willing
# to test their environments, provide feedback on content for the next release, and
# for people looking for early-access to next release content.
#
# The CR repo is shipped in a disabled state by default; its important that users
# understand the implications of turning this on.
#
# NOTE: We do not use a mirrorlist for the CR repos, to ensure content is available
#       to everyone as soon as possible, and not need to wait for the external
#       mirror network to seed first. However, many local mirrors will carry CR repos
#       and if desired you can use one of these local mirrors by editing the baseurl
#       line in the repo config below.
#

[cr]
name=CentOS-$releasever - cr
baseurl=http://mirror.centos.org/centos/$releasever/cr/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=1
repo_gpgcheck=1
#protect=0
#priority=1
EOFCR


#########################
## CentOS-SCLo-scl.repo
#########################

cat >> ${BACKUPDIR}/yum.repos.d/CentOS-SCLo-scl.repo << 'EOFSCL'
# CentOS-SCLo-sclo.repo
#
# Please see http://wiki.centos.org/SpecialInterestGroup/SCLo for more
# information

[centos-sclo-sclo]
name=CentOS-7 - SCLo sclo
baseurl=http://mirror.centos.org/centos/7/sclo/$basearch/sclo/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo
#protect=0
#priority=4

## repo gpgcheck not enabled for sclo-scl
repo_gpgcheck=0


[centos-sclo-sclo-testing]
name=CentOS-7 - SCLo sclo Testing
baseurl=http://buildlogs.centos.org/centos/7/sclo/$basearch/sclo/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo

[centos-sclo-sclo-source]
name=CentOS-7 - SCLo sclo Sources
baseurl=http://vault.centos.org/centos/7/sclo/Source/sclo/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo

[centos-sclo-sclo-debuginfo]
name=CentOS-7 - SCLo sclo Debuginfo
baseurl=http://debuginfo.centos.org/centos/7/sclo/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo

EOFSCL

############################
## CentOS-SCLo-scl-rh.repo
############################

cat >> ${BACKUPDIR}/yum.repos.d/CentOS-SCLo-scl-rh.repo << 'EOFSCLRH'
# CentOS-SCLo-rh.repo
#
# Please see http://wiki.centos.org/SpecialInterestGroup/SCLo for more
# information

[centos-sclo-rh]
name=CentOS-7 - SCLo rh
baseurl=http://mirror.centos.org/centos/7/sclo/$basearch/rh/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo
#protect=0
#priority=4

## repo gpgcheck not enabled for sclo-rh
repo_gpgcheck=0


[centos-sclo-rh-testing]
name=CentOS-7 - SCLo rh Testing
baseurl=http://buildlogs.centos.org/centos/7/sclo/$basearch/rh/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo

[centos-sclo-rh-source]
name=CentOS-7 - SCLo rh Sources
baseurl=http://vault.centos.org/centos/7/sclo/Source/rh/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo

[centos-sclo-rh-debuginfo]
name=CentOS-7 - SCLo rh Debuginfo
baseurl=http://debuginfo.centos.org/centos/7/sclo/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo

EOFSCLRH

##############
## epel.repo
##############

cat >> ${BACKUPDIR}/yum.repos.d/epel.repo << 'EOFEPEL'
[epel]
name=Extra Packages for Enterprise Linux 7 - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
#protect=1
priority=10

## repo gpgcheck not enabled for epel
repo_gpgcheck=0


[epel-debuginfo]
name=Extra Packages for Enterprise Linux 7 - $basearch - Debug
#baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch/debug
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-7&arch=$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux 7 - $basearch - Source
#baseurl=http://download.fedoraproject.org/pub/epel/7/SRPMS
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-source-7&arch=$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
gpgcheck=1

EOFEPEL

#####################
## DEPLOY NEW FILES
#####################

/bin/cp -f ${BACKUPDIR}/yum.conf /etc/yum.conf
chown root:root /etc/yum.conf
chmod       644 /etc/yum.conf

/bin/cp -f ${BACKUPDIR}/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
chown root:root /etc/yum.repos.d/CentOS-Base.repo
chmod       644 /etc/yum.repos.d/CentOS-Base.repo

/bin/cp -f ${BACKUPDIR}/yum.repos.d/CentOS-CR.repo /etc/yum.repos.d/CentOS-CR.repo
chown root:root /etc/yum.repos.d/CentOS-CR.repo
chmod       644 /etc/yum.repos.d/CentOS-CR.repo

/bin/cp -f ${BACKUPDIR}/yum.repos.d/CentOS-SCLo-scl.repo /etc/yum.repos.d/CentOS-SCLo-scl.repo
chown root:root /etc/yum.repos.d/CentOS-SCLo-scl.repo
chmod       644 /etc/yum.repos.d/CentOS-SCLo-scl.repo

/bin/cp -f ${BACKUPDIR}/yum.repos.d/CentOS-SCLo-scl-rh.repo /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
chown root:root /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
chmod       644 /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo

/bin/cp -f ${BACKUPDIR}/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo
chown root:root /etc/yum.repos.d/epel.repo
chmod       644 /etc/yum.repos.d/epel.repo

##########################################
## IMPORT RPM KEYS
## CCE-26957-1 Ensure GPG Keys Installed
##########################################

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

###########################
# SHOW ALL INSTALLED KEYS
###########################

echo "post-install keys"
rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'

#timestamp
echo "** security_hardening_repos.sh COMPLETE" $(date +%F-%H%M-%S)
