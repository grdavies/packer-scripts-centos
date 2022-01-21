#!/usr/bin/env bash
##############################################################################
## Hardening for Modprobe
##############################################################################
## Files modified
##
## /etc/modprobe.d/filesystem-hardening.conf
## /etc/modprobe.d/network-hardening.conf
## /etc/modprobe.d/bluetooth-hardening.con
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
echo "** security_hardening_modprobe.sh START" $(date +%F-%H%M-%S)

# Ensure packages are installed
yum install -y kmod

##################
## SET VARIBLES
##################

BACKUPDIR=/root/KShardening/modprobe.d/

#################
## BACKUP FILES
#################

if [ ! -d "${BACKUPDIR}" ]; then mkdir -p ${BACKUPDIR}; fi


####################
## WRITE NEW FILES
####################

###################################
## /etc/modprobe.d/filesystem-hardening.conf
###################################

cat > ${BACKUPDIR}/filesystem-hardening.conf << 'EOFFS'

# Note: some older recomendations use /bin/false
# but that is no longer recommended
# https://github.com/OpenSCAP/scap-security-guide/issues/539

### DISABLE UNCOMMON FILESYSTEM TYPES

### CCE-80137-3 Disable Mounting of cramfs
install cramfs /bin/true

### CCE-80138-1 Disable Mounting of freevxfs
install freevxfs /bin/true

### CCE-80139-9 Disable Mounting of jffs2
install jffs2 /bin/true

### CCE-80140-7 Disable Mounting of hfs
install hfs /bin/true

### CCE-80141-5 Disable Mounting of hfsplus
install hfsplus /bin/true

### CCE-80142-3 Disable Mounting of squashfs
### NOTE: if you run signularity, don't disable this
install squashfs /bin/true

### CCE-80143-1 Disable Mounting of udf
install udf /bin/true

EOFFS

###################################
## /etc/modprobe.d/network-hardening.conf
###################################

cat > ${BACKUPDIR}/network-hardening.conf << 'EOFNET'

### DISABLE UNCOMMON NETWORK PROTOCOLS

### CCE-26828-4 Disable Datagram Congestion Control Protocol (DCCP) Support
install dccp /bin/true

### CCE-27106-4 Disable Stream Control Transmission Protocol (SCTP) Support
install sctp /bin/true

### CCE-RHEL7-CCE-TBD Disable Reliable Datagram Sockets (RDS) Support
install rds /bin/true

### CCE-RHEL7-CCE-TBD Disable Transparent Inter-Process Communication (TIPC) Support
install tipc /bin/true

EOFNET

###################################
## /etc/modprobe.d/bluetooth-hardening.conf
###################################

cat > ${BACKUPDIR}/bluetooth-hardening.conf << 'EOFBLUE'

### CCE-27327-6 Disable Bluetooth Kernel Modules
install bluetooth /bin/true

EOFBLUE

###################################
## /etc/modprobe.d/usb-hardening.conf
###################################

cat > ${BACKUPDIR}/usb-hardening.conf << 'EOFUSB'

### CCE-27277-3 Disable Modprobe Loading of USB Storage Driver
### Administrators can selectively enable with:
### insmod usb-storage
install usb-storage /bin/true

EOFUSB


#####################
## DEPLOY NEW FILES
#####################

/bin/cp -f ${BACKUPDIR}/filesystem-hardening.conf /etc/modprobe.d/filesystem-hardening.conf
/bin/chown root:root                              /etc/modprobe.d/filesystem-hardening.conf
/bin/chmod       644                              /etc/modprobe.d/filesystem-hardening.conf

/bin/cp -f ${BACKUPDIR}/network-hardening.conf /etc/modprobe.d/network-hardening.conf
/bin/chown root:root                           /etc/modprobe.d/network-hardening.conf
/bin/chmod       644                           /etc/modprobe.d/network-hardening.conf

/bin/cp -f ${BACKUPDIR}/bluetooth-hardening.conf /etc/modprobe.d/bluetooth-hardening.conf
/bin/chown root:root                             /etc/modprobe.d/bluetooth-hardening.conf
/bin/chmod       644                             /etc/modprobe.d/bluetooth-hardening.conf

/bin/cp -f ${BACKUPDIR}/usb-hardening.conf /etc/modprobe.d/usb-hardening.conf
/bin/chown root:root                       /etc/modprobe.d/usb-hardening.conf
/bin/chmod       644                       /etc/modprobe.d/usb-hardening.conf


## Note: may need to restore context when done

#timestamp
echo "** security_hardening_modprobe.sh COMPLETE" $(date +%F-%H%M-%S)
