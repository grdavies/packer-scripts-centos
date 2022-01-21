#!/usr/bin/env bash
##############################################################################
## Hardening for passwords
##############################################################################
## Files modified
##
## /etc/login.defs
## /etc/security/pwquality.conf
## /etc/default/useradd
##
## Also see c7-pam.cfg for configuration of:
## /etc/pam.d/system-auth
## /etc/pam.d/password-auth
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-passwords.cfg
##
##############################################################################
## Notes
##
##############################################################################

#timestamp
echo "** security_hardening_passwords.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y shadow-utils \
                libpwquality

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening

# For future use

PW_MAXAGE=60
PW_MINAGE=7
PW_LEN=15
PW_WARN=7

PW_RETRY=3
PW_UP=1
PW_LOW=1
PW_NUM=1
PW_OTH=1
PW_DIFF=4
PW_REUSE=5

PW_EXPIRE=35

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}/security" ]; then mkdir -p ${BACKUPDIR}/security; fi

/bin/cp -fpd /etc/login.defs ${BACKUPDIR}/login.defs-DEFAULT
/bin/cp -fpd /etc/security/pwquality.conf ${BACKUPDIR}/security/pwquality.conf-DEFAULT

mkdir -p ${BACKUPDIR}/default

/bin/cp -fpd /etc/default/useradd ${BACKUPDIR}/default/useradd-DEFAULT

####################
## WRITE NEW FILES
####################

###################
# /etc/login.defs
###################

cat > ${BACKUPDIR}/login.defs << 'EOFLOGIN'
#
# Please note that the parameters in this configuration file control the
# behavior of the tools from the shadow-utils component. None of these
# tools uses the PAM mechanism, and the utilities that use PAM (such as the
# passwd command) should therefore be configured elsewhere. Refer to
# /etc/pam.d/system-auth for more information.
#

# *REQUIRED*
#   Directory where mailboxes reside, _or_ name of file, relative to the
#   home directory.  If you _do_ define both, MAIL_DIR takes precedence.
#   QMAIL_DIR is for Qmail
#
#QMAIL_DIR	Maildir
MAIL_DIR	/var/spool/mail
#MAIL_FILE	.mail

# Password aging controls:
#
#	PASS_MAX_DAYS	Maximum number of days a password may be used.
#	PASS_MIN_DAYS	Minimum number of days allowed between password changes.
#	PASS_MIN_LEN	Minimum acceptable password length.
#	PASS_WARN_AGE	Number of days warning given before a password expires.
#
## CCE-27051-2 Set Password Maximum Age ( 60 days )
PASS_MAX_DAYS	60
## CCE-27002-5 Set Password Minimum Age (  7 days )
PASS_MIN_DAYS	1
## Set Password Minimum Length ( 15 characters ) ( Also in pwquality.conf )
PASS_MIN_LEN	15
## CCE-26988-6 Set Password Warning Age (  7 days )
PASS_WARN_AGE	7

#
# Min/max values for automatic uid selection in useradd
#
UID_MIN                  1000
UID_MAX                 60000
# System accounts
SYS_UID_MIN               201
SYS_UID_MAX               999

#
# Min/max values for automatic gid selection in groupadd
#
GID_MIN                  1000
GID_MAX                 60000
# System accounts
SYS_GID_MIN               201
SYS_GID_MAX               999

#
# If defined, this command is run when removing a user.
# It should remove any at/cron/print jobs etc. owned by
# the user to be removed (passed as the first argument).
#
#USERDEL_CMD	/usr/sbin/userdel_local

#
# If useradd should create home directories for users by default
# On RH systems, we do. This option is overridden with the -m flag on
# useradd command line.
#
CREATE_HOME	yes

# The permission mask is initialized to this value. If not specified,
# the permission mask will be initialized to 022.
UMASK           077

# This enables userdel to remove user groups if no members exist.
#
USERGROUPS_ENAB yes

# Use SHA512 to encrypt password.
ENCRYPT_METHOD SHA512

# Ensure the Logon Failure Delay is Set Correctly
FAIL_DELAY 4

EOFLOGIN

################################
# /etc/security/pwquality.conf
################################

cat > ${BACKUPDIR}/security/pwquality.conf << 'EOFQUALITY'
# Configuration for systemwide password quality limits
# Defaults:
#
# Number of characters in the new password that must not be present in the
# old password.
### CCE-26631-2 Set Password Strength Minimum Different Characters ( 4 characters )
difok = 5

# Minimum acceptable size for the new password (plus one if
# credits are not disabled which is the default). (See pam_cracklib manual.)
# Cannot be set to lower value than 6.
### CCE-27293-0 Set Password Minimum Length ( 15 characters )
minlen = 15

# The maximum credit for having digits in the new password. If less than 0
# it is the minimum number of digits in the new password.
### CCE-27214-6 Set Password Strength Minimum Digit Characters ( 1 digit )
dcredit = -1

# The maximum credit for having uppercase characters in the new password.
# If less than 0 it is the minimum number of uppercase characters in the new
# password.
### CCE-27200-5 Set Password Strength Minimum Uppercase Characters ( 1 upper )
ucredit = -1

# The maximum credit for having lowercase characters in the new password.
# If less than 0 it is the minimum number of lowercase characters in the new
# password.
### CCE-27345-8 Set Password Strength Minimum Lowercase Characters ( 1 lower )
lcredit = -1

# The maximum credit for having other characters in the new password.
# If less than 0 it is the minimum number of other characters in the new
# password.
### CCE-27360-7 Set Password Strength Minimum Special Characters ( 1 special )
ocredit = -1

# The minimum number of required classes of characters for the new
# password (digits, uppercase, lowercase, others).
# minclass = 0
#
# The maximum number of allowed consecutive same characters in the new password.
# The check is disabled if the value is 0.
# maxrepeat = 0
#
# The maximum number of allowed consecutive characters of the same class in the
# new password.
# The check is disabled if the value is 0.
# maxclassrepeat = 0
#
# Whether to check for the words from the passwd entry GECOS string of the user.
# The check is enabled if the value is not 0.
# gecoscheck = 0
#
# Path to the cracklib dictionaries. Default is to use the cracklib default.
# dictpath =
EOFQUALITY

#########################
## /etc/default/useradd
#########################

cat > ${BACKUPDIR}/default/useradd << 'EOFADD'
# useradd defaults file
GROUP=100
HOME=/home
# CCE-27355-7 Set Account Expiration Following Inactivity ( 35 days )
INACTIVE=35
EXPIRE=
SHELL=/bin/bash
SKEL=/etc/skel
CREATE_MAIL_SPOOL=yes
EOFADD

#####################
## DEPLOY NEW FILES
#####################

/bin/cp -f ${BACKUPDIR}/login.defs /etc/login.defs
/bin/chown root:root /etc/login.defs
/bin/chmod       644 /etc/login.defs

/bin/cp -f ${BACKUPDIR}/security/pwquality.conf /etc/security/pwquality.conf
/bin/chown root:root /etc/security/pwquality.conf
/bin/chmod       644 /etc/security/pwquality.conf

/bin/cp -f ${BACKUPDIR}/default/useradd /etc/default/useradd
/bin/chown root:root /etc/default/useradd
/bin/chmod       644 /etc/default/useradd

#timestamp
echo "** security_hardening_passwords.sh COMPLETE" $(date +%F-%H%M-%S)
