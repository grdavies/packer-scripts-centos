#!/usr/bin/env bash
##############################################################################
## Hardening for PAM
##############################################################################
## Files modified
##
## /etc/pam.d/system-auth-ac
## /etc/pam.d/password-auth-ac
## /etc/pam.d/su
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-pam.cfg
##
##############################################################################
## Notes
##
## Linux Password Enforcement with Pam
## http://www.deer-run.com/~hal/linux_passwords_pam.html
##
## Red Hat Enterprise Linux 7 Security Guide
## https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Security_Guide/
## 4.1.2. Account Locking
## https://access.redhat.com/solutions/62949
## https://access.redhat.com/discussions/1404353
##
##############################################################################

#timestamp
echo "** security_hardening_template.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y authconfig \
                util-linux

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening/pam.d

# For future use
ATTEMPS=5
INTERVAL=900
LOCKOUT=900
UNLOCK=604800
REUSE=5

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}" ]; then mkdir -p ${BACKUPDIR}; fi

/bin/cp -fpd /etc/pam.d/su                ${BACKUPDIR}/su-DEFAULT
/bin/cp -fpd /etc/pam.d/system-auth-ac    ${BACKUPDIR}/system-auth-ac-DEFAULT
/bin/cp -fpd /etc/pam.d/password-auth-ac  ${BACKUPDIR}/password-auth-ac-DEFAULT

####################
## WRITE NEW FILES
####################

##################
## /etc/pam.d/su
##################

cat > ${BACKUPDIR}/su << 'EOFSU'
#%PAM-1.0
auth            sufficient      pam_rootok.so
# Uncomment the following line to implicitly trust users in the "wheel" group.
#auth           sufficient      pam_wheel.so trust use_uid
# CIS 6.5 Restrict Access to the su Command
# Uncomment the following line to require a user to be in the "wheel" group.
auth            required        pam_wheel.so use_uid
auth            substack        system-auth
auth            include         postlogin
account         sufficient      pam_succeed_if.so uid = 0 use_uid quiet
account         include         system-auth
password        include         system-auth
session         include         system-auth
session         include         postlogin
session         optional        pam_xauth.so
EOFSU


####################################################
# system-auth-ac
# Note: system-auth is a symlink to system-auth-ac
####################################################

cat > ${BACKUPDIR}/system-auth-ac-forcedreset << 'EOFSYSTEM'
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth        required      pam_env.so

## CCE-27286-4 Prevent Log In to Accounts With Empty Password
## Remove any instances of the null ok option in /etc/pam.d/system-auth

## CCE-27350-8 Set Deny For Failed Password Attempts
## CCE-26884-7 Set Lockout Time For Failed Password Attempts
## CIS 6.3.3 Set Lockout for Failed Password Attempts
## Lockout users if 5 failed attempts within 15 mins until reset
## Admins unlock with: /usr/sbin/faillock --user <user> --reset
auth required pam_faillock.so preauth silent deny=5 unlock_time=604800 fail_interval=900

auth        sufficient    pam_unix.so  try_first_pass

## CCE-27350-8 Set Deny For Failed Password Attempts
## CCE-26884-7 Set Lockout Time For Failed Password Attempts
## CIS 6.3.3 Set Lockout for Failed Password Attempts
auth [default=die] pam_faillock.so authfail deny=5 unlock_time=604800 fail_interval=900

auth        requisite     pam_succeed_if.so uid >= 1000 quiet_success
auth        required      pam_deny.so

## CCE-27350-8 Set Deny For Failed Password Attempts
## CIS 6.3.3 Set Lockout for Failed Password Attempts
account     required      pam_faillock.so

account     required      pam_unix.so
account     sufficient    pam_localuser.so
account     sufficient    pam_succeed_if.so uid < 1000 quiet
account     required      pam_permit.so

# CCE-27160-1 Set Password Retry Prompts Permitted Per-Session ( 3 retries )
password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=

## CCE-26923-3 Limit Password Reuse ( 5 passwords )
## CIS 6.3.4   Limit Password Reuse
## Old passwords are saved in /etc/security/opasswd
password    sufficient    pam_unix.so sha512 shadow  try_first_pass use_authtok remember=5

password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so
EOFSYSTEM

## Like above but resets locked accounts automatically after 15 mins

cat > ${BACKUPDIR}/system-auth-ac-autoreset << 'EOFSYSTEM2'
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth        required      pam_env.so

## CCE-27286-4 Prevent Log In to Accounts With Empty Password
## Remove any instances of the null ok option in /etc/pam.d/system-auth

## Lockout users after 5 failed attempts, but unlock after 15 mins
auth        required       pam_faillock.so preauth silent audit deny=5 unlock_time=900

auth        sufficient    pam_unix.so try_first_pass

## Lockout users after 5 failed attempts, but unlock after 15 mins
auth [default=die]  pam_faillock.so authfail audit deny=5 unlock_time=900

auth        requisite     pam_succeed_if.so uid >= 1000 quiet_success
auth        required      pam_deny.so

account     required      pam_unix.so
account     sufficient    pam_localuser.so
account     sufficient    pam_succeed_if.so uid < 1000 quiet
account     required      pam_permit.so

## CCE-27160-1 Set Password Retry Prompts Permitted Per-Session ( 3 retries )
password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=

## CCE-26923-3 Limit Password Reuse ( 5 passwords )
## CIS 6.3.4   Limit Password Reuse
## Old passwords are saved in /etc/security/opasswd
password    sufficient    pam_unix.so sha512 shadow try_first_pass use_authtok remember=5

password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so

EOFSYSTEM2

## No account lockout

cat > ${BACKUPDIR}/system-auth-ac-nolockout << 'EOFSYSTEM3'
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth        required      pam_env.so

## CCE-27286-4 Prevent Log In to Accounts With Empty Password
## Remove any instances of the null ok option in /etc/pam.d/system-auth

auth        sufficient    pam_unix.so try_first_pass
auth        requisite     pam_succeed_if.so uid >= 1000 quiet_success
auth        required      pam_deny.so

account     required      pam_unix.so
account     sufficient    pam_localuser.so
account     sufficient    pam_succeed_if.so uid < 1000 quiet
account     required      pam_permit.so

## CCE-27160-1 Set Password Retry Prompts Permitted Per-Session ( 3 retries )
password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=

## CCE-26923-3 Limit Password Reuse ( 5 passwords )
## CIS 6.3.4   Limit Password Reuse
## Old passwords are saved in /etc/security/opasswd
password    sufficient    pam_unix.so sha512 shadow try_first_pass use_authtok remember=5

password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so

EOFSYSTEM3

####################################################
# password-auth-ac
# Note: password-auth is a symlink to system-auth-ac
####################################################

cat > ${BACKUPDIR}/password-auth-ac-forcedreset << 'EOFPASSWORD'
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth        required      pam_env.so

## CCE-27350-8 Set Deny For Failed Password Attempts
## CCE-26884-7 Set Lockout Time For Failed Password Attempts
## CIS 6.3.3 Set Lockout for Failed Password Attempts
## Lockout users if 5 failed attempts within 15 mins until reset
## Locked accounts will unlock after a week.
## Admins unlock with: /usr/sbin/faillock --user <user> --reset
auth required pam_faillock.so preauth silent deny=5 unlock_time=604800 fail_interval=900

auth        sufficient    pam_unix.so nullok try_first_pass

## CCE-27350-8 Set Deny For Failed Password Attempts
## CCE-26884-7 Set Lockout Time For Failed Password Attempts
## CIS 6.3.3 Set Lockout for Failed Password Attempts
auth [default=die] pam_faillock.so authfail deny=5 unlock_time=604800 fail_interval=900

auth        requisite     pam_succeed_if.so uid >= 1000 quiet_success
auth        required      pam_deny.so

## CCE-27350-8 Set Deny For Failed Password Attempts
## CIS 6.3.3 Set Lockout for Failed Password Attempts
account     required      pam_faillock.so

account     required      pam_unix.so
account     sufficient    pam_localuser.so
account     sufficient    pam_succeed_if.so uid < 1000 quiet
account     required      pam_permit.so

password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok
password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so
EOFPASSWORD

## Like above but resets locked accounts automatically after 15 mins

cat > ${BACKUPDIR}/password-auth-ac-autoreset << 'EOFPASSWORD2'
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth        required      pam_env.so

## Lockout users after 5 failed attempts, but unlock after 15 mins
auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900

auth        sufficient    pam_unix.so nullok try_first_pass

## Lockout users after 5 failed attempts, but unlock after 15 mins
auth [default=die]  pam_faillock.so authfail audit deny=5 unlock_time=900

auth        requisite     pam_succeed_if.so uid >= 1000 quiet_success
auth        required      pam_deny.so

## CCE-27350-8 Set Deny For Failed Password Attempts
## CIS 6.3.3 Set Lockout for Failed Password Attempts
account     required      pam_faillock.so

account     required      pam_unix.so
account     sufficient    pam_localuser.so
account     sufficient    pam_succeed_if.so uid < 1000 quiet
account     required      pam_permit.so

password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok
password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so

EOFPASSWORD2

## No account lockout

cat > ${BACKUPDIR}/password-auth-ac-nolockout << 'EOFPASSWORD3'
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth        required      pam_env.so
auth        sufficient    pam_unix.so nullok try_first_pass
auth        requisite     pam_succeed_if.so uid >= 1000 quiet_success
auth        required      pam_deny.so

account     required      pam_unix.so
account     sufficient    pam_localuser.so
account     sufficient    pam_succeed_if.so uid < 1000 quiet
account     required      pam_permit.so

password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok
password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so

EOFPASSWORD3

## /etc/pam.d/su

cat > ${BACKUPDIR}/su << 'EOFSU'
#%PAM-1.0
auth		sufficient	pam_rootok.so
# Uncomment the following line to implicitly trust users in the "wheel" group.
#auth		sufficient	pam_wheel.so trust use_uid
# CIS 6.5 Restrict Access to the su Command
# Uncomment the following line to require a user to be in the "wheel" group.
auth		required	pam_wheel.so use_uid
auth		substack	system-auth
auth		include		postlogin
account		sufficient	pam_succeed_if.so uid = 0 use_uid quiet
account		include		system-auth
password	include		system-auth
session		include		system-auth
session		include		postlogin
session		optional	pam_xauth.so
EOFSU

#####################
## DEPLOY NEW FILES
#####################
#
# There are three options for system-auth-ac and password-auth-ac
#
# forcedreset  	Accounts are locked after 5 failed attempts in 15 mintues
#		Administrators must reset them
#
# autoreset   	Accounts are locked after 5 failed attempts in 15 minutes
#		Accounts are automatically reset after another 15 minutes
#
# nolockout	Account lockout not enabled.
#		Other security settings are.

/bin/cp -f ${BACKUPDIR}/su /etc/pam.d/su
/bin/chown root:root /etc/pam.d/su
/bin/chmod       644 /etc/pam.d/su

/bin/cp -f ${BACKUPDIR}/system-auth-ac-forcedreset /etc/pam.d/system-auth-ac
/bin/chown root:root /etc/pam.d/system-auth-ac
/bin/chmod       644 /etc/pam.d/system-auth-ac

/bin/cp -f ${BACKUPDIR}/password-auth-ac-forcedreset /etc/pam.d/password-auth-sc
/bin/chown root:root /etc/pam.d/password-auth-ac
/bin/chmod       644 /etc/pam.d/password-auth-ac

#timestamp
echo "** security_hardening_template.sh COMPLETE" $(date +%F-%H%M-%S)
