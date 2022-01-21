#!/usr/bin/env bash
##############################################################################
## Hardening for Sysctl
##############################################################################
## Files modified
##
## /etc/sysctl.d/80-sysctl-hardening.conf
## /etc/sysctl.d/81-forwarding.conf
## /etc/sysctl.d/82-ipv6.conf
## /etc/security/limits.conf
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-sysctl.cfg
##
##############################################################################
## Notes
##
##############################################################################

#timestamp
echo "** security_hardening_sysctl.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y initscripts \
                pam

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}/security" ]; then mkdir -p ${BACKUPDIR}/security; fi

/bin/cp -Rfpd /etc/sysctl.d            ${BACKUPDIR}/sysctl.d-DEFAULT
/bin/cp -fpd /etc/security/limits.conf ${BACKUPDIR}/security/limits.conf-DEFAULT

####################
## WRITE NEW FILES
####################

#####################
## /etc/sysctl.conf
#####################

cat > ${BACKUPDIR}/80-sysctl-hardening.conf << 'EOF'
# For more information, see sysctl.conf(5) and sysctl.d(5).

### CCE-27050-4 Restrict Access to Kernel Message Buffer
kernel.dmesg_restrict = 1

### CCE-27127-0 Enable Randomized Layout of Virtual Address Space
### CIS 1.6.3   Enable Randomized Virtual Memory Region Placement
kernel.randomize_va_space = 2

### CCE-26900-1 Disable Core Dumps for SUID programs
### CIS 1.6.1 Restrict Core Dumps
fs.suid_dumpable = 0

EOF

cat > ${BACKUPDIR}/81-ipv4-hardening.conf << 'EOFIPV4'
### CCE-80156-3 Disable Kernel Parameter for Sending ICMP Redirects for All Interfaces
### CCE-80156-3 Disable Kernel Parameter for Sending ICMP Redirects by Default
### CIS 4.1.2   Disable Send Packet Redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

### CCE-27434-0 Disable Kernel Parameter for Accepting Source-Routed Packets for All Interfaces
### CCE-80162-1 Disable Kernel Parameter for Accepting Source-Routed Packets By Default
### CIS 4.2.1   Disable Source Routed Packet Acceptance
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

### CCE-80158-9 Disable Kernel Parameter for Accepting ICMP Redirects for All Interfaces
### CCE-80164-7 Disable Kernel Parameter for Accepting Secure Redirects By Default
### CIS 4.2.2   Disable ICMP Redirect Acceptance
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

### CCE-80159-7 Disable Kernel Parameter for Accepting Secure Redirects for All Interfaces
### CIS 4.2.3   Disable Secure ICMP Redirect Acceptance ( Level 2 )
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

### CCE-80160-5 Enable Kernel Parameter to Log Martian Packets
### CCE-80161-3 Enable Kernel Parameter to Log Martian Packets By Default
### CIS 4.2.4 Log Suspicious Packets ( aka martians )
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

### CCE-80165-4 Enable Kernel Parameter to Ignore ICMP Broadcast Echo Requests
### CIS 4.2.5   Enable Ignore Broadcast Requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

### CCE-80166-2 Enable Kernel Parameter to Ignore Bogus ICMP Error Responses
### CIS 4.2.6   Enable Bad Error Message Protection
net.ipv4.icmp_ignore_bogus_error_responses = 1

### CCE-27495-1 Enable Kernel Parameter to Use TCP Syncookies
### CIS 4.2.8   Enable TCP SYN Cookies
net.ipv4.tcp_syncookies = 1

### CCE-80167-0 Enable Kernel Parameter to Use Reverse Path Filtering for All Interfaces
### CCE-80168-8 Enable Kernel Parameter to Use Reverse Path Filtering by Default
### CIS 4.2.7 Enable RFC-recommended Source Route Validation ( Level 2 )
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

EOFIPV4

cat > ${BACKUPDIR}/82-forwarding.conf << 'EOFFORW'
### CCE-80157-1 Disable Kernel Parameter for IP Forwarding
### CIS 4.1.1   Disable IP Forwarding
net.ipv4.ip_forward = 0

# Enable Forwarding
#net.ipv4.ip_forward = 1

# To manually enable forwarding use:
# sysctl -w net.ipv4.ip_forward=1

# see current status
# cat /proc/sys/net/ipv4/ip_forward

EOFFORW


cat > ${BACKUPDIR}/83-ipv6-hardening.conf << 'EOFIPV6'
### CCE-80175-3 Disable IPv6 Networking Support Automatic Loading
#net.ipv6.conf.all.disable_ipv6 = 1

### CCE-80180-3 Disable Accepting IPv6 Router Advertisements
### CCE-80181-1 Disable Accepting IPv6 Router Advertisements
### CIS 4.4.1.1 Disable IPv6 Router Advertisements
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0

### CCE-80182-9 Disable Accepting IPv6 Redirects
### CCE-80183-7 Disable Accepting IPv6 Redirects By Default
### CIS 4.4.1.2 Disable IPv6 Redirect Acceptance
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

### Disable Accepting Source-Routed Packets for All Interfaces
net.ipv6.conf.all.accept_source_route = 0

EOFIPV6

#############################
# /etc/security/limits.conf
#############################

cat > ${BACKUPDIR}/security/limits.conf << 'EOFLIMITS'
# /etc/security/limits.conf
#
#This file sets the resource limits for the users logged in via PAM.
#It does not affect resource limits of the system services.
#
#Also note that configuration files in /etc/security/limits.d directory,
#which are read in alphabetical order, override the settings in this
#file in case the domain is the same or more specific.
#That means for example that setting a limit for wildcard domain here
#can be overriden with a wildcard setting in a config file in the
#subdirectory, but a user specific setting here can be overriden only
#with a user specific setting in the subdirectory.
#
#Each line describes a limit for a user in the form:
#
#<domain>        <type>  <item>  <value>
#
#Where:
#<domain> can be:
#        - a user name
#        - a group name, with @group syntax
#        - the wildcard *, for default entry
#        - the wildcard %, can be also used with %group syntax,
#                 for maxlogin limit
#
#<type> can have the two values:
#        - "soft" for enforcing the soft limits
#        - "hard" for enforcing hard limits
#
#<item> can be one of the following:
#        - core - limits the core file size (KB)
#        - data - max data size (KB)
#        - fsize - maximum filesize (KB)
#        - memlock - max locked-in-memory address space (KB)
#        - nofile - max number of open file descriptors
#        - rss - max resident set size (KB)
#        - stack - max stack size (KB)
#        - cpu - max CPU time (MIN)
#        - nproc - max number of processes
#        - as - address space limit (KB)
#        - maxlogins - max number of logins for this user
#        - maxsyslogins - max number of logins on the system
#        - priority - the priority to run user process with
#        - locks - max number of file locks the user can hold
#        - sigpending - max number of pending signals
#        - msgqueue - max memory used by POSIX message queues (bytes)
#        - nice - max nice priority allowed to raise to values: [-20, 19]
#        - rtprio - max realtime priority
#
#<domain>      <type>  <item>         <value>
#

#*               soft    core            0
#*               hard    rss             10000
#@student        hard    nproc           20
#@faculty        soft    nproc           20
#@faculty        hard    nproc           50
#ftp             hard    nproc           0
#@student        -       maxlogins       4

# CCE-80169-6 Disable Core Dumps for All Users
# CIS 1.6.1   Restrict Core Dumps
*      		hard	core		0

### CCE-27457-1 Limit the Number of Concurrent Login Sessions Allowed Per User ( 3 )
*               hard    maxlogins       3

# End of file
EOFLIMITS

#####################
## DEPLOY NEW FILES
#####################

/bin/cp -f ${BACKUPDIR}/80-sysctl-hardening.conf /etc/sysctl.d/80-sysctl-hardening.conf
/bin/chown root:root                             /etc/sysctl.d/80-sysctl-hardening.conf
/bin/chmod       644                             /etc/sysctl.d/80-sysctl-hardening.conf

/bin/cp -f ${BACKUPDIR}/81-ipv4-hardening.conf /etc/sysctl.d/81-ipv4-hardening.conf
/bin/chown root:root                           /etc/sysctl.d/81-ipv4-hardening.conf
/bin/chmod       644                           /etc/sysctl.d/81-ipv4-hardening.conf

/bin/cp -f ${BACKUPDIR}/82-forwarding.conf /etc/sysctl.d/82-forwarding.conf
/bin/chown root:root                       /etc/sysctl.d/82-forwarding.conf
/bin/chmod       644                       /etc/sysctl.d/82-forwarding.conf

/bin/cp -f ${BACKUPDIR}/83-ipv6-hardening.conf /etc/sysctl.d/83-ipv6-hardening.conf
/bin/chown root:root                           /etc/sysctl.d/83-ipv6-hardening.conf
/bin/chmod       644                           /etc/sysctl.d/83-ipv6-hardening.conf

/bin/cp -f ${BACKUPDIR}/security/limits.conf /etc/security/limits.conf
/bin/chown root:root                         /etc/security/limits.conf
/bin/chmod       644                         /etc/security/limits.conf

#timestamp
echo "** security_hardening_sysctl.sh COMPLETE" $(date +%F-%H%M-%S)
