#!/usr/bin/env bash
##############################################################################
## Hardening for oscap
##############################################################################
## Files modified
##
## /root/openscap_data/*
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-oscap.cfg
##
##############################################################################
## Notes
##
## OpenSCAP User Manual
## https://static.open-scap.org/openscap-1.2/oscap_user_manual.html
##
##############################################################################

#timestamp
echo "** security_hardening_oscap.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y @security-tools \
                openscap \
                openscap-scanner \
                openscap-utils \
                scap-security-guide \
                scap-security-guide-doc \
                xmlsec1 \
                xmlsec1-openssl \
                unzip \
                tar \
                gzip

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening
OSCAPDIR=/root/openscap_data

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}" ]; then mkdir -p ${BACKUPDIR}; fi

if [ ! -d "${OSCAPDIR}" ];  then mkdir -p ${OSCAPDIR}; fi

####################
## WRITE NEW FILES
####################

# Here Files
# http://tldp.org/LDP/abs/html/here-docs.html
# Note: No parameter substitution when the "limit string" is quoted or escaped.

# Download latest evaulation proceedures

curl -o ${OSCAPDIR}/evaluate.txt  -L https://bitbucket.org/carlisle/hardening-ks/raw/master/evaluate.txt

curl -o ${OSCAPDIR}/c7-evaluate_scap_1.36.sh  -L https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-evaluate_scap_1.36.sh
curl -o ${OSCAPDIR}/c7-evaluate_scap_1.39.sh  -L https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-evaluate_scap_1.39.sh


##########################
## security audit script
##########################

cat > ${BACKUPDIR}/audit_security.sh << 'EOF'
# Security Tests

printf "========================================\n"
printf "= Performing Security Tests = $(date +%F) at $(date +%H%M) =\n"
printf "========================================\n"
printf "List all filesystems: \n\n"
df --local -P | awk {'if (NR!=1) print $6'}

printf "========================================\n"
printf "Show system executables that don't have root ownership: \n\n"
find /bin/ /usr/bin/ /usr/local/bin/ /sbin/ /usr/sbin/ /usr/local/sbin/ /usr/libexec \! -user root -exec ls -l {} \;

printf "========================================\n"
printf "Show files that differ from expected file hashes\n"
printf "These will report files modified due to hardening: \n\n"
rpm -Va | grep '^..5'

printf "========================================\n"
printf "Find SUID Executables in local filesystems:\n\n"
## CIS 6.1.13 Audit SUID executables
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' \
find '{}' -xdev -type f -perm -4000 -print
# to search selected file systems use:
# find ${filesystem} -xdev -type f -perm -4000

printf "========================================\n"
printf "Verfiy integrity of the SUID binaries returned by above:\n\n"
## CCE-80133-2 Ensure All SUID Executables Are Authorized
SUIDFILES=$(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -4000 -print)
for I in $SUIDFILES; do echo "Integrity of $I:  "; rpm -V $(rpm -qf $I ); echo; done

printf "========================================\n"
printf "Find SGID Executables in local filesystems:\n\n"
# CIS 6.1.14 Audit SGID executables
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' \
find '{}' -xdev -type f -perm -2000 -print
# to search selected file systems use:
# find ${filesystem} -xdev -type f -perm -2000

printf "========================================\n"
printf "Verfiy integrity of SGID binaries returned by above:\n\n"
## CCE-80132-4 Ensure All SGID Executables Are Authorized
SGIDFILES=$(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -2000 -print)
for I in $SGIDFILES; do echo "Integrity of $I:  "; rpm -V $(rpm -qf $I ); echo; done

printf "========================================\n"
printf "Show all World-Writable Directories that don't have the Sticky Bits Set:\n\n"
## CIS 1.1.21  Ensure sticky bit is set on all world-writable directories
## CCE-80130-8 Verify that All World-Writable Directories Have Sticky Bits Set
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' \
find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null

printf "========================================\n"
printf "Show all World-Writable Files:\n\n"
## CIS 9.1.10 Find World Writable Files
## CCE-80131-6 Ensure No World-Writable Files Exist
# Ensure No World-Writable Files Exist
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' \
find '{}' -xdev -type f -perm -0002

printf "========================================\n"
printf "Show Un-owned Files and Directories in local file systems\n\n"
# Ensure All Files Are Owned by a User
# CIS 6.1.11 Ensure no unowned files or directories exist
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' \
find '{}' -xdev -nouser -ls
# to search selected file systems use:
# find ${filesystem} -xdev -nouser

printf "========================================\n"
printf "Show Un-grouped Files and Directories in local file systems\n\n"
# Ensure All Files Are Owned by a Group
# CIS 6.1.12 Ensure no ungrouped files or directories exist
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' \
find '{}' -xdev -nogroup -ls
# to search selected file systems use:
# find ${filesystem} -xdev -nogroup

printf "========================================\n"
printf "Ensure All World-Writable Directories Are Owned by a System Account\n\n"
# Ensure All World-Writable Directories Are Owned by a System Account
# Assumes system accounts have uid < $FIRSTUSER
FIRSTUSER=1000
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' \
find '{}' -xdev -type d -perm -0002 -uid +$FIRSTUSER -print

printf "========================================\n"
printf "Verify integrity of passwd, shadow, and group files\n\n"
# Verify integrity of passwd shadow and group files

pwck -r
grpck -r

printf "========================================\n"
printf "Show all empty password fields\n\n"
# CIS 6.2.1 Ensure password fields are not empty
/bin/cat /etc/shadow | /bin/awk -F: '($2 == "" ) { print $1 " does not have a password "}'

printf "========================================\n"
printf "Show umask in bashrc and profile\n\n"
# CIS 5.4.4 Ensure default user umask is 027 or more restrictive
grep "umask" /etc/bashrc /etc/profile /etc/profile.d/*.sh

printf "========================================\n"
printf "Show user directories with .rhosts, .netrc, or .forward files\n\n"
# CIS 6.2.14 Ensure no users have .rhosts files
# CIS 6.2.12 Ensure no users have .netrc files
# CIS 6.2.11 Ensure no users have .forward files
HOMEDIR=$(/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' \
 | /bin/awk -F: '($7 != "/sbin/nologin") { print $6 }')
for file in ${HOMEDIR}/.rhosts; do
    if [ ! -h "${FILE}" -a -f "${FILE}" ]; then
      echo ".rhosts file ${HOMEDIR}/.rhosts exists"
      echo ".netrc file ${HOMEDIR}/.netrc exists"
      echo ".forward file ${HOMEDIR}/.forward exists"
    fi
done

printf "========================================\n"
printf "sysctl configuration:\n"
printf "The following should be set to 0:\n\n"

sysctl --all | grep net.ipv4.conf.default.send_redirects
sysctl --all | grep net.ipv4.conf.all.send_redirects
sysctl --all | grep "net.ipv4.ip_forward "
sysctl --all | grep net.ipv4.conf.all.accept_source_route
sysctl --all | grep net.ipv4.conf.all.accept_redirects
sysctl --all | grep net.ipv4.conf.all.secure_redirects
sysctl --all | grep fs.suid_dumpable

printf "\nThe following should be set to 1:\n\n"
sysctl --all | grep net.ipv4.conf.all.log_martians
sysctl --all | grep net.ipv4.conf.default.log_martians
sysctl --all | grep net.ipv4.icmp_echo_ignore_broadcasts
sysctl --all | grep net.ipv4.icmp_ignore_bogus_error_responses

printf "\nThe following should be set to 0:\n\n"
sysctl --all | grep net.ipv4.conf.default.accept_source_route
sysctl --all | grep net.ipv4.conf.all.accept_redirects
sysctl --all | grep net.ipv4.conf.default.secure_redirects
#sysctl --all | grep net.ipv4.icmp_echo_ignore_broadcasts
#sysctl --all | grep net.ipv4.icmp_ignore_bogus_error_responses
sysctl --all | grep net.ipv4.tcp_syncookies
sysctl --all | grep net.ipv4.conf.all.rp_filter
sysctl --all | grep net.ipv4.conf.default.rp_filter
sysctl --all | grep net.ipv6.conf.all.disable_ipv6
sysctl --all | grep "net.ipv6.conf.all.accept_ra "
sysctl --all | grep "net.ipv6.conf.default.accept_ra "
sysctl --all | grep net.ipv6.conf.all.accept_redirects
sysctl --all | grep net.ipv6.conf.default.accept_redirects

printf "========================================\n"
printf "other\n\n"

#are these running: rxinetd telnet-server rsh-server ypserv tftp-server
#find -type f -name .rhosts -exec rm -f '{}' \;
#rm /etc/hosts.equiv

EOF

#####################
## DEPLOY NEW FILES
#####################

chown root:root ${OSCAPDIR}/c7-evaluate_scap_*.sh
chmod 700       ${OSCAPDIR}/c7-evaluate_scap_*.sh

#timestamp
echo "** security_hardening_oscap.sh COMPLETE" $(date +%F-%H%M-%S)
