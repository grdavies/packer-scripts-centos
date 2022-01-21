#!/usr/bin/env bash
##############################################################################
## Hardening for firewalld
##############################################################################
## Files modified
##
## /etc/firewalld/firewalld.conf
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-sshd.cfg
##
##############################################################################
## Notes
##
##############################################################################

#timestamp
echo "** security_hardening_sshd.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y openssh-server \
                openssh-clients

#################
## SET BASH ERREXIT OPTION
#################
set -o errexit

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}" ]; then mkdir -p ${BACKUPDIR}; fi

/bin/cp -fpd /etc/ssh/sshd_config ${BACKUPDIR}/sshd_config-DEFAULT
/bin/cp -fpd /etc/ssh/ssh_config  ${BACKUPDIR}/ssh_config-DEFAULT
/bin/cp -fpd /etc/issue     ${BACKUPDIR}/issue-DEFAULT
/bin/cp -fpd /etc/issue.net ${BACKUPDIR}/issue.net-DEFAULT
/bin/cp -fpd /etc/motd      ${BACKUPDIR}/motd-DEFAULT


####################
## WRITE NEW FILES
####################

### Updated sshd_config for Centos 7.7.1908 with openssh 7.4p1

cat > ${BACKUPDIR}/sshd_config << 'EOFSSHD'
#    $OpenBSD: sshd_config,v 1.100 2016/08/15 12:32:04 naddy Exp $

# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/local/bin:/usr/bin

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

# If you want to change the port on a SELinux system, you have to tell
# SELinux about this change.
# semanage port -a -t ssh_port_t -p tcp #PORTNUMBER
Port 22

#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

### openssh 7.4p1 no longer allows ssh protocol 1, this entry is redundant.
### CIS 5.2.2 Ensure SSH Protocol is set to 2
### CCE-27320-1 Allow Only SSH Protocol 2
Protocol 2

HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
SyslogFacility AUTHPRIV

### CIS 5.2.3 Ensure SSH LogLevel is set to INFO
LogLevel INFO

# Authentication:

### CIS 5.2.14 Ensure SSH LoginGraceTime is set to one minute or less
LoginGraceTime 60

### CIS 5.2.8 Ensure SSH root login is disabled
### CCE-27445-6 Disable SSH Root Login
PermitRootLogin no
###PermitRootLogin without-password

### CCE-80222-3 Enable Use of Strict Mode Checking
StrictModes yes

### CIS 5.2.5 Ensure SSH MaxAuthTries is set to 4 or less
MaxAuthTries 4

#MaxSessions 10

#PubkeyAuthentication yes

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
AuthorizedKeysFile    .ssh/authorized_keys

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

### CIS 5.2.7 Ensure SSH HostbasedAuthentication is disabled
### CCE-27413-4 Disable Host-Based Authentication
# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
HostbasedAuthentication no

### CCE-80372-6 Disable SSH Support for User Known Hosts
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
IgnoreUserKnownHosts yes

### CIS 5.2.6 Ensure SSH IgnoreRhosts is enabled
### CCE-27377-1 Disable SSH Support for .rhosts Files
# Don't read the user's ~/.rhosts and ~/.shosts files
IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
#PasswordAuthentication yes

### CIS 5.2.9 Ensure SSH PermitEmptyPasswords is disabled
### CCE-27471-2 Disable SSH Access via Empty Passwords
PermitEmptyPasswords no
PasswordAuthentication yes

# Change to no to disable s/key passwords
#ChallengeResponseAuthentication yes
ChallengeResponseAuthentication no

### CCE-80221-5 Disable Kerberos Authentication
# Kerberos options
KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no
#KerberosUseKuserok yes

### CCE-80220-7 Disable GSSAPI Authentication
# GSSAPI options
GSSAPIAuthentication no
GSSAPICleanupCredentials no
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no
#GSSAPIEnablek5users no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
# WARNING: 'UsePAM no' is not supported in Red Hat Enterprise Linux and may cause several
# problems.
UsePAM yes

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no

### CIS 5.2.4 Ensure SSH X11 forwarding is disabled unless needed
X11Forwarding no
###X11Forwarding yes
#X11DisplayOffset 10
#X11UseLocalhost yes

#PermitTTY yes
#PrintMotd yes

### CCE-80225-6 Print Last Log
PrintLastLog yes

#TCPKeepAlive yes
#UseLogin no

### CCE-80223-1 Enable Use of Privilege Separation
### UsePrivilegeSeparation yes
UsePrivilegeSeparation sandbox

### CIS 5.2.10 Ensure SSH PermitUserEnvironment is disabled
### CCE-27363-1 Do Not Allow SSH Environment Options
PermitUserEnvironment no

### CCE-80224-9 Disable Compression Or Set Compression to delayed
Compression delayed

### CIS 5.2.13 Ensure SSH Idle Timeout Interval is configured
### CCE-27433-2 Set SSH Idle Timeout Interval
### CCE-27082-7 Set SSH Client Alive Count
ClientAliveInterval 300         # 5 minutes
#ClientAliveInterval 14400      # 4 hours
ClientAliveCountMax 0

#ShowPatchLevel no
#UseDNS yes
#PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

### CIS 5.2.16 Ensure SSH warning banner is configured
### CCE-27314-4 Enable SSH Warning Banner
Banner /etc/issue.net

# Accept locale-related environment variables
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS

### CCE-80373-4 Disable SSH Support for Rhosts RSA Authentication
### Deprecated
#RhostsRSAAuthentication no

### CIS 5.2.11 Ensure only approved ciphers are used
### CCE-27295-5 Use Only FIPS 140-2 Validated Ciphers
# Ciphers aes256-ctr,aes192-ctr,aes128-ctr

Ciphers aes256-ctr,aes192-ctr,aes128-ctr,aes256-gcm@openssh.com,aes128-gcm@openssh.com,chacha20-poly1305@openssh.com

### CIS 5.2.12 Ensure only approved MAC algorithms are used
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com

### CCE-27455-5 Use Only FIPS 140-2 Validated MACs
# MACs hmac-sha2-512,hmac-sha2-256

# https://access.redhat.com/solutions/4278651
#
# key exchange algorithms
kexalgorithms curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha256

### CIS 5.2.15 Ensure SSH access is limited
#AllowUsers <userlist>
#AllowGroups wheel
#DenyUsers <userlist>
#DenyGroups <grouplist>

# override default of no subsystems
Subsystem    sftp    /usr/libexec/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
#    X11Forwarding no
#    AllowTcpForwarding no
#    PermitTTY no
#    ForceCommand cvs server

EOFSSHD

##############################################
## WRITE NEW BANNER MESSAGES
##############################################

cat >> ${BACKUPDIR}/Banner.txt << 'EOFBANNER'

-- WARNING -- This system is for the use of authorized users only. Individuals
using this computer system without authority or in excess of their authority
are subject to having all their activities on this system monitored and
recorded by system personnel. Anyone using this system expressly consents to
such monitoring and is advised that if such monitoring reveals possible
evidence of criminal activity system personal may provide the evidence of such
monitoring to law enforcement officials.

EOFBANNER

/bin/cp -fpd ${BACKUPDIR}/Banner.txt ${BACKUPDIR}/issue
/bin/cp -fpd ${BACKUPDIR}/Banner.txt ${BACKUPDIR}/issue.net
/bin/cp -fpd ${BACKUPDIR}/Banner.txt ${BACKUPDIR}/motd

# Customized these files before deployment here.

###################
## audit-sshd.sh
###################

cat > ${BACKUPDIR}/audit_sshd.sh << 'EOFAUDIT'
#!/usr/bin/env bash

# Audit sshd config file

printf '%s\n' "Audit /etc/ssh/sshd_config file"
printf '%s\n' "Allow Only SSH Protocol 2"
cat /etc/ssh/sshd_config | grep Protocol

printf '\n%s\n' "Disable GSSAPI Authentication"
cat /etc/ssh/sshd_config | grep GSSAPIAuthentication

printf '\n%s\n' "Disable Kerberos Authentication"
cat /etc/ssh/sshd_config | grep KerberosAuthentication

printf '\n%s\n' "Enable Use of Strict Mode Checking"
cat /etc/ssh/sshd_config | grep StrictModes

printf '\n%s\n' "Disable Compression Or Set Compression to delayed"
cat /etc/ssh/sshd_config | grep Compression

printf '\n%s\n' "Enable Use of Privilege Separation"
cat /etc/ssh/sshd_config | grep UsePrivilegeSeparation

printf '\n%s\n' "Set LogLevel to INFO"
cat /etc/ssh/sshd_config | grep LogLevel

printf '\n%s\n' "MaxAuthTries"
cat /etc/ssh/sshd_config | grep MaxAuthTries

printf '\n%s\n' "Disable Host-Based Authentication"
cat /etc/ssh/sshd_config | grep HostbasedAuthentication

printf '\n%s\n' "Disable SSH Support for .rhosts Files"
cat /etc/ssh/sshd_config | grep IgnoreRhosts

printf '\n%s\n' "Disable SSH Support for User Known Hosts"
cat /etc/ssh/sshd_config | grep IgnoreUserKnownHosts

printf '\n%s\n' "Disable SSH Support for Rhosts RSA Authentication"
cat /etc/ssh/sshd_config | grep RhostsRSAAuthentication

printf '\n%s\n' "Disable SSH Root Login"
cat /etc/ssh/sshd_config | grep PermitRootLogin

printf '\n%s\n' "Disable SSH Access via Empty Passwords"
cat /etc/ssh/sshd_config | grep PermitEmptyPasswords

printf '\n%s\n' "Disable X11 Forwarding, unless needed"
cat /etc/ssh/sshd_config | grep X11Forwarding

printf '\n%s\n' "Do Not Allow SSH Environment Options"
cat /etc/ssh/sshd_config | grep PermitUserEnvironment

printf '\n%s\n' "Set SSH Idle Timeout Interval"
cat /etc/ssh/sshd_config | grep ClientAliveInterval

printf '\n%s\n' "Set SSH Client Alive Count"
cat /etc/ssh/sshd_config | grep ClientAliveCountMax

printf '\n%s\n' "Enable SSH Warning Banner"
cat /etc/ssh/sshd_config | grep Banner

printf '\n%s\n' "Print Last Log"
cat /etc/ssh/sshd_config | grep PrintLastLog

printf '\n%s\n' "Limit allowed users, if possible"
cat /etc/ssh/sshd_config | grep AllowUsers

printf '\n%s\n' "Limit allowed groups, if possible"
cat /etc/ssh/sshd_config | grep AllowGroups

printf '\n%s\n' "Deny certain users, if possible"
cat /etc/ssh/sshd_config | grep DenyUsers

printf '\n%s\n' "Deny certain groups, if possible"
cat /etc/ssh/sshd_config | grep DenyGroups

printf '\n%s\n' "Disable CBC Mode Ciphers"
cat /etc/ssh/sshd_config | grep Ciphers

printf '\n%s\n' "Disable any 96-bit HMAC Algorithms.Disable any MD5-based HMAC Algorithms"
cat /etc/ssh/sshd_config | grep MACs

# Audit ssh_config file
printf '\n%s\n' "#### Audit ssh_config file ####"
printf '\n%s\n' "Allow Only SSH Protocol 2"
cat /etc/ssh/ssh_config | grep Protocol

printf '\n%s\n' "Enable HashKnownHosts to obscure destination servers"
cat /etc/ssh/ssh_config | grep HashKnownHosts

# Audit ssh config file permissions

printf '\n%s' "#### Verify ssh config file permissions ####"
printf '\n%s\n' "/etc/ssh should be 755"
ls -ld /etc/ssh

printf '\n%s\n' "/etc/ssh/sshd_config should be 600"
ls -l  /etc/ssh/sshd_config

printf '\n%s\n' "ssh server public keys should be 644 and owned by root"
ls -l  /etc/ssh/*.pub

printf '\n%s\n' "ssh server private keys should be 640 and owned by root"
ls -l  /etc/ssh/*_key

# Audit ssh file for root

printf '\n%s' "#### Verify root ssh file permissions ####"
printf '\n%s\n' "root home directory must be 750 or better and owned by root"
ls -ld /root

printf '\n%s\n' "root .ssh directory must be 700 and owned by the root"
ls -ld /root/.ssh

printf '\n%s\n' "root private keys must be 600 and owned by the root"
ls -l  /root/.ssh/id_*

printf '\n%s\n' "root known_hosts should be 644 or better and owned by the root"
ls -l  /root/.ssh/known_hosts

printf '\n%s\n' "root authorized_keys file should be 600 and owned by the root"
ls -l  /root/.ssh/authorized_keys

ls -l  /root/.ssh/config

ls -l  /root/.ssh/*

# Audit ssh files for users
printf '\n%s' "#### Verify user ssh file permissions ####"
printf '\n%s\n' "User home directories should not be writable by others"
ls -ld /home/*

printf '\n%s\n' "User ssh directories must be 700 and owned by the user"
ls -ld /home/*/.ssh

printf '\n%s\n' "User private keys must be 600 and owned by the user. dsa keys should not be used."
ls -l  /home/*/.ssh/id_*

printf '\n%s\n' "User known_hosts should be 644 or better and owned by the user. dsa keys should not be used."
ls -l  /home/*/.ssh/known_hosts

printf '\n%s\n' "authorized_keys file should be 600 and owned by the user"
ls -l  /home/*/.ssh/authorized_keys

ls -l  /home/*/.ssh/config

ls -l  /home/*/.ssh/*

EOFAUDIT


#####################
## DEPLOY NEW FILES
#####################

### CIS 6.2.3 Set Permissions on /etc/ssh/sshd_config
/bin/cp -f ${BACKUPDIR}/sshd_config /etc/ssh/sshd_config
/bin/chown root:root /etc/ssh/sshd_config
/bin/chmod 0600      /etc/ssh/sshd_config

### CCE-27311-0 Verify Permissions on SSH Server Public *.pub Key Files
/bin/chown root:root /etc/ssh/*.pub
/bin/chmod 0644      /etc/ssh/*.pub

### CCE-27485-2 Verify Permissions on SSH Server Private *_key Key Files
/bin/chown root:root /etc/ssh/*_key
/bin/chmod 0644      /etc/ssh/*_key

/bin/cp -fpd ${BACKUPDIR}/issue /etc/issue
/bin/chown root:root /etc/issue
/bin/chmod 0644      /etc/issue

/bin/cp -fpd ${BACKUPDIR}/issue.net /etc/issue.net
/bin/chown root:root /etc/issue.net
/bin/chmod 0644      /etc/issue.net

/bin/cp -fpd ${BACKUPDIR}/motd /etc/motd
/bin/chown root:root /etc/motd
/bin/chmod 0644      /etc/motd

####################
## TURN ON SERVICE
####################

systemctl enable  sshd

#timestamp
echo "** security_hardening_sshd.sh COMPLETE" $(date +%F-%H%M-%S)
