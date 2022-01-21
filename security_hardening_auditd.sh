#!/usr/bin/env bash
##############################################################################
## Hardening for auditd
##############################################################################
## Files modified
##
## /etc/audit/auditd.conf
## /etc/audit/rules.d/*
## /etc/audisp/plugins.d/syslog.conf
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
## https://bitbucket.org/carlisle/hardening-ks/raw/master/centos7/c7-auditd.cfg
##
##############################################################################
## Notes
##
##############################################################################

#timestamp
echo "** security_hardening_template.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y audit

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}/rules.d" ]; then mkdir -p ${BACKUPDIR}/rules.d; fi

/bin/cp -Rfpd /etc/audit                       ${BACKUPDIR}/audit-DEFAULT
/bin/cp -fpd /etc/audisp/plugins.d/syslog.conf ${BACKUPDIR}/audisp-syslog.conf-DEFAULT

/bin/rm -rf /etc/audit/rules.d/*

####################
## WRITE NEW FILES
####################

###################
## auditd.conf
###################

cat > ${BACKUPDIR}/auditd.conf << 'EOF'
#
# This file controls the configuration of the audit daemon
#

local_events = yes
write_logs = yes
log_file = /var/log/audit/audit.log
log_group = root
log_format = RAW
priority_boost = 4
###flush = INCREMENTAL_ASYNC
freq = 50
###max_log_file = 8
###num_logs = 5
priority_boost = 4
disp_qos = lossy
dispatcher = /sbin/audispd
name_format = NONE
##name = mydomain
###max_log_file_action = ROTATE
space_left = 75
###space_left_action = SYSLOG
###action_mail_acct = root
admin_space_left = 50
###admin_space_left_action = SUSPEND
disk_full_action = SUSPEND
disk_error_action = SUSPEND
use_libwrap = yes
##tcp_listen_port =
tcp_listen_queue = 5
tcp_max_per_addr = 1
##tcp_client_ports = 1024-65535
tcp_client_max_idle = 0
enable_krb5 = no
krb5_principal = auditd
##krb5_key_file = /etc/audit/audit.key

### CCE-27348-2 Configure auditd Number of Logs Retained
### Max number is 99
num_logs = 5

### CCE-27319-3 Configure auditd Max Log File Size in MB
max_log_file = 20

### CCE-27231-0 Configure auditd max_log_file_action Upon Reaching Maximum Log Size
### Possible values: IGNORE, SYSLOG, SUSPEND, ROTATE, KEEP_LOGS
max_log_file_action = ROTATE
### CIS 5.2.1.3 Keep All Auditing Information ( Level 2 )
# max_log_file_action = KEEP_LOGS

### CCE-27375-5 Configure auditd space_left Action on Low Disk Space
### Acceptable values: EMAIL, SUSPEND, SINGLE, HALT
space_left_action = EMAIL

### CCE-27394-6 Configure auditd mail_acct Action on Low Disk Space
### Also alias email from root to the admins
action_mail_acct = root

### CCE-27370-6 Configure auditd admin_space_left Action on Low Disk Space
### Acceptable values: SINGLE, SUSPEND, HALT
admin_space_left_action = SINGLE

### CIS 5.2.1.2 Disable System on Audit Log Full ( Level 2 )
# space_left_action = email
# admin_space_left_action = halt

### CCE-27331-8 Configure auditd flush priority
flush = DATA

EOF

###################
## audit.rules
###################

cat > ${BACKUPDIR}/rules.d/audit.rules << 'EOFRULES'
# This file contains the auditctl rules that are loaded
# whenever the audit daemon is started via the initscripts.
# The rules are simply the parameters that would be passed
# to auditctl.

# First rule - delete all
-D

# Increase the buffers to survive stress events.
# Make this bigger for busy systems
-b 8192

# Feel free to add below this line. See auditctl man page

EOFRULES

###########################
## audit_time_rules.rules 2
###########################

cat > ${BACKUPDIR}/rules.d/audit_time_rules.rules << 'EOFTIME'
## CIS 5.2.4 Record Events That Modify Date and Time Information ( Level 2 )

## CCE-27290-6  Record attempts to alter time through adjtimex
## CCE-27216-1  Record attempts to alter time through settimeofday
## CCE-27299-7  Record attempts to alter time through stime

## The following covers 32bit and 64bit systems
-a always,exit -F arch=b32 -S stime                 -F key=audit_time_rules
-a always,exit -F arch=b32 -S adjtimex,settimeofday -F key=audit_time_rules
-a always,exit -F arch=b64 -S adjtimex,settimeofday -F key=audit_time_rules

## CCE-27219-5  Record Attempts to Alter Time Through clock_settime
-a always,exit -F arch=b32 -S clock_settime -F a0=0x0 -F key=time-change
-a always,exit -F arch=b64 -S clock_settime -F a0=0x0 -F key=time-change

#-a always,exit -F arch=b32 -S clock_settime -k audit_time_rules
#-a always,exit -F arch=b64 -S clock_settime -k audit_time_rules

## CCE-27310-2  Record Attempts to Alter the localtime File
-w /etc/localtime -p wa -k audit_time_rules

EOFTIME


#############################################
## audit_rules_usergroup_modification.rules 2
#############################################

cat > ${BACKUPDIR}/rules.d/audit_rules_usergroup_modification.rules << 'EOFUSERGROUP'
## CIS 5.2.5 Record Events That Modify User/Group Information ( Level 2 )
## CCE-27192-4  Record Events that Modify User/Group Information
-w /etc/group            -p wa -k audit_rules_usergroup_modification
-w /etc/passwd           -p wa -k audit_rules_usergroup_modification
-w /etc/gshadow          -p wa -k audit_rules_usergroup_modification
-w /etc/shadow           -p wa -k audit_rules_usergroup_modification
-w /etc/security/opasswd -p wa -k audit_rules_usergroup_modification

EOFUSERGROUP


#################################################
## audit_rules_networkconfig_modification.rules 2
#################################################

cat > ${BACKUPDIR}/rules.d/audit_rules_networkconfig_modification.rules << 'EOFNETWORK'
## CIS 5.2.6 Record Events That Modify the System's Network Environment ( Level 2 )
## CCE-27076-9  Record Events that Modify the System's Network Environment

-a always,exit -F arch=b64 -S sethostname,setdomainname -F key=audit_rules_networkconfig_modification
-w /etc/issue -p wa -k audit_rules_networkconfig_modification
-w /etc/issue.net -p wa -k audit_rules_networkconfig_modification
-w /etc/hosts -p wa -k audit_rules_networkconfig_modification
-w /etc/sysconfig/network -p wa -k audit_rules_networkconfig_modification

EOFNETWORK


###################
## logins.rules
###################

cat > ${BACKUPDIR}/rules.d/logins.rules << 'EOFLOGINS'
## CIS 5.2.8 Collect Login and Logout Events ( Level 2 )
## CCE-27204-7  Record Attempts to Alter Logon and Logout Events
-w /var/log/tallylog -p wa -k logins
-w /var/run/faillock/ -p wa -k logins
-w /var/log/lastlog -p wa -k logins

EOFLOGINS


###################
## session.rules
###################

cat > ${BACKUPDIR}/rules.d/session.rules << 'EOFSESSION'
## CIS 5.2.9 Collect Session Initiation Information ( Level 2 )
## CCE-27301-1  Record Attempts to Alter Process and Session Initiation Information
-w /var/run/utmp -p wa -k session
-w /var/log/btmp -p wa -k session
-w /var/log/wtmp -p wa -k session

EOFSESSION


###################
## access.rules 2
###################

cat > ${BACKUPDIR}/rules.d/access.rules << 'EOFACCESS'
## CIS 5.2.11 Collect Unsuccessful Unauthorized Access Attempts to Files ( Level 2 )
## CCE-27347-4  Ensure auditd Collects Unauthorized Access Attempts to Files (unsuccessful)
-a always,exit -F arch=b32 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=access
-a always,exit -F arch=b32 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EPERM  -F auid>=1000 -F auid!=unset -F key=access
-a always,exit -F arch=b64 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=access
-a always,exit -F arch=b64 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EPERM  -F auid>=1000 -F auid!=unset -F key=access

EOFACCESS


####################
## privleged.rules
####################

cat > ${BACKUPDIR}/rules.d/privleged.rules << 'EOFPRIV'
## CIS 5.2.12 Collect Use of Privileged Commands ( Level 2 )
## CCE-27437-3  Ensure auditd Collects Information on the Use of Privileged Commands
# To re-generate this list, run this:
# df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' \
# find '{}' -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print \
# "-a always,exit -F path=" $1 " -F perm=x -F auid>=1000 -F auid!=4294967295 \
# -k privileged" }'
-a always,exit -F path=/usr/sbin/pam_timestamp_check -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/sbin/unix_chkpwd -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/sbin/netreport -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/sbin/postdrop -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/sbin/postqueue -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/sbin/usernetctl -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/newgrp -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/gpasswd -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/ssh-agent -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/su -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/chsh -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/crontab -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/write -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/wall -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/screen -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/mount -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/pkexec -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/chage -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/chfn -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/passwd -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/umount -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/bin/at -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/libexec/openssh/ssh-keysign -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/libexec/utempter/utempter -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/lib64/dbus-1/dbus-daemon-launch-helper -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/usr/lib/polkit-1/polkit-agent-helper-1 -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged

-a always,exit -F path=/usr/bin/userhelper -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged
-a always,exit -F path=/usr/bin/sudoedit -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged

EOFPRIV


###################
## export.rules 2
###################

cat > ${BACKUPDIR}/rules.d/export.rules << 'EOFEXPORT'
## CIS 5.2.13  Collect Successful File System Mounts ( Level 2 )
## CCE-27447-2 Ensure auditd Collects Information on Exporting to Media (successful)
-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=unset -F key=export

EOFEXPORT


###################
## actions.rules 2
###################

cat > ${BACKUPDIR}/rules.d/actions.rules << 'EOFACTIONS'
## CIS 5.2.16 Collect System Administrator Actions (sudolog) ( Level 2 )
## CCE-27461-3  Ensure auditd Collects System Administrator Actions
-w /etc/sudoers    -p wa -k actions
-w /etc/sudoers.d/ -p wa -k actions

## CIS 5.2.15 Collect Changes to System Administration Scope ( Level 2 )
-w /etc/sudoers -p wa -k scope

EOFACTIONS


###################
## modules.rules 2
###################

cat > ${BACKUPDIR}/rules.d/modules.rules << 'EOFMODULES'
## CCE-27129-6  Ensure auditd Collects Information on Kernel Module Loading and Unloading
## CIS 5.2.17 Collect Kernel Module Loading and Unloading ( Level 2 )
-w /usr/sbin/insmod -p x -k modules
-w /usr/sbin/rmmod -p x -k modules
-w /usr/sbin/modprobe -p x -k modules
-a always,exit -F arch=b32 -S init_module,finit_module,delete_module -F key=modules
-a always,exit -F arch=b64 -S init_module,finit_module,delete_module -F key=modules
EOFMODULES

####################
## immutable.rules
####################

cat > ${BACKUPDIR}/rules.d/immutable.rules << 'EOFIMMUTE'
## CIS 5.2.18 Make the Audit Configuration Immutable ( Level 2)
## CCE-27097-5 Make the auditd Configuration Immutable
## With this setting, a reboot will be required to change any audit rules.
#-e 2

EOFIMMUTE


###################
## perm_mod.rules 2
###################

cat > ${BACKUPDIR}/rules.d/perm_mod.rules << 'EOFPERM'
## CIS 5.2.10 Collect Discretionary Access Control
## Permission Modification Events ( Level 2 )
## Record Events that Modify the System's Discretionary Access Controls
## Enabling these policies will make filesystem changes noticeably slower

## CCE-27339-1  chmod
## CCE-27393-8  fchmod
## CCE-27388-8  fchmodat
-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=unset -F key=perm_mod
-a always,exit -F arch=b64 -S chmod,fchomd,fchmodat -F auid>=1000 -F auid!=unset -F key=perm_mod


## CCE-27356-5  fchown
## CCE-27364-9  chown
## CCE-27387-0  fchownat
## CCE-27083-5  lchown
-a always,exit -F arch=b32 -S fchown,chown,fchownat -F auid>=1000 -F auid!=unset -F key=perm_mod
-a always,exit -F arch=b64 -S fchown,chown,fchownat -F auid>=1000 -F auid!=unset -F key=perm_mod


## CCE-27213-8  setxattr
## CCE-27367-2  removexattr
## CCE-27353-2  fremovexattr
## CCE-27280-7  lsetxattr
## CCE-27410-0  lremovexattr
## CCE-27389-6  fsetxattr
-a always,exit -F arch=b32 -S setxattr,removexattr,fremovexattr,lsetxattr,lremovexattr,fsetxattr -F auid>=1000 -F auid!=unset -F key=perm_mod
-a always,exit -F arch=b64 -S setxattr,removexattr,fremovexattr,lsetxattr,lremovexattr,fsetxattr -F auid>=1000 -F auid!=unset -F key=perm_mod

EOFPERM


#####################
## MAC-policy.rules 2
#####################

cat > ${BACKUPDIR}/rules.d/MAC-policy.rules << 'EOFMAC'
## NOTE: Enabling these policies will make filesystem changes noticeably slower

## CIS 5.2.7    Record Events That Modify the System's Mandatory Access Controls ( Level 2 )
## CCE-27168-4  Record Events that Modify the System's Mandatory Access Controls

-w /etc/selinux/ -p wa -k MAC-policy

EOFMAC


###################
## delete.rules 2
###################

cat > ${BACKUPDIR}/rules.d/delete.rules << 'EOFDELETE'
## NOTE: Enabling these policies will make filesystem changes noticeably slower

## CIS 5.2.14 Collect File Deletion Events by User ( Level 2 )
## CCE-27206-2  Ensure auditd Collects File Deletion Events by User
-a always,exit -F arch=b64 -S rmdir,unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=unset -F key=delete

EOFDELETE


###################
## selinux.rules
###################

cat > ${BACKUPDIR}/rules.d/selinux.rules << 'EOFSEL'
## Record Execution Attempts to Run SELinux Privileged Commands

-a always,exit -F path=/usr/sbin/semanage -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged-priv_change
-a always,exit -F path=/usr/sbin/setsebool -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged-priv_change
-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged-priv_change
-a always,exit -F path=/usr/sbin/restorecon -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged-priv_change

EOFSEL


#######################
## audisp-syslog.conf
#######################

cat > ${BACKUPDIR}/audisp-syslog.conf << 'EOFSYSLOG'
# This file controls the configuration of the syslog plugin.
# It simply takes events and writes them to syslog. The
# arguments provided can be the default priority that you
# want the events written with. And optionally, you can give
# a second argument indicating the facility that you want events
# logged to. Valid options are LOG_LOCAL0 through 7.

### CCE-27341-7 Configure auditd to use audispd's syslog plugin
#active = yes
active = no

direction = out
path = builtin_syslog
type = builtin
args = LOG_INFO
format = string

EOFSYSLOG

#############################
## postboot-auditd.txt
#############################

cat > ${BACKUPDIR}/postboot-auditd.txt << 'EOFPOST'

Once final audit rules have been determined,
enable immutables configuration in /etc/audit/audit.rules

### CCE-27212-0 Enable Auditing for Processes Which Start Prior to the Audit Daemon
# To ensure all processes can be audited, even those which start prior to the
# audit daemon, add the argument audit=1 to the default GRUB 2 command line
# for the Linux operating system in /etc/default/grub
#
# GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=VolGroup/LogVol06 rd.lvm.lv=VolGroup/lv_swap rhgb quiet rd.shell=0 audit=1"
#
# On BIOS-based machines: grub2-mkconfig -o /boot/grub2/grub.cfg
# On UEFI-based machines: grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg

EOFPOST

#####################
## DEPLOY NEW FILES
#####################

/bin/cp -f ${BACKUPDIR}/auditd.conf /etc/audit/auditd.conf
/bin/chown root:root /etc/audit/auditd.conf
/bin/chmod       640 /etc/audit/auditd.conf

/bin/cp -f ${BACKUPDIR}/rules.d/audit.rules            /etc/audit/rules.d/audit.rules
/bin/cp -f ${BACKUPDIR}/rules.d/audit_time_rules.rules /etc/audit/rules.d/audit_time_rules.rules
/bin/cp -f ${BACKUPDIR}/rules.d/audit_rules_usergroup_modification.rules      /etc/audit/rules.d/audit_rules_usergroup_modification.rules
/bin/cp -f ${BACKUPDIR}/rules.d/audit_rules_networkconfig_modification.rules  /etc/audit/rules.d/audit_rules_networkconfig_modification.rules
/bin/cp -f ${BACKUPDIR}/rules.d/logins.rules           /etc/audit/rules.d/logins.rules
/bin/cp -f ${BACKUPDIR}/rules.d/session.rules          /etc/audit/rules.d/session.rules
/bin/cp -f ${BACKUPDIR}/rules.d/access.rules           /etc/audit/rules.d/access.rules
/bin/cp -f ${BACKUPDIR}/rules.d/privleged.rules        /etc/audit/rules.d/privleged.rules
/bin/cp -f ${BACKUPDIR}/rules.d/export.rules           /etc/audit/rules.d/export.rules
/bin/cp -f ${BACKUPDIR}/rules.d/actions.rules          /etc/audit/rules.d/actions.rules
/bin/cp -f ${BACKUPDIR}/rules.d/modules.rules          /etc/audit/rules.d/modules.rules
/bin/cp -f ${BACKUPDIR}/rules.d/immutable.rules        /etc/audit/rules.d/immutable.rules
/bin/cp -f ${BACKUPDIR}/rules.d/selinux.rules          /etc/audit/rules.d/selinux.rules


## Enabling the following policies will make filesystem changes noticeably slower

/bin/cp -f ${BACKUPDIR}/rules.d/perm_mod.rules         /etc/audit/rules.d/perm_mod.rules
/bin/cp -f ${BACKUPDIR}/rules.d/MAC-policy.rules       /etc/audit/rules.d/MAC-policy.rules
/bin/cp -f ${BACKUPDIR}/rules.d/delete.rules           /etc/audit/rules.d/delete.rules


/bin/chown root:root /etc/audit/rules.d/*.rules
/bin/chmod       640 /etc/audit/rules.d/*.rules

## Enabling this option sends all audit logs to syslog to ensure that audit logs
## can be send to a remote logging server

#/bin/cp -f ${BACKUPDIR}/audisp-syslog.conf /etc/audisp/plugins.d/syslog.conf
#/bin/chown root:root /etc/audisp/plugins.d/syslog.conf
#/bin/chmod       640 /etc/audisp/plugins.d/syslog.conf

####################
## TURN ON SERVICE
####################

systemctl enable auditd.service

#timestamp
echo "** security_hardening_template.sh COMPLETE" $(date +%F-%H%M-%S)
