#!/usr/bin/env bash
#
# Disable SELinux
#

sed -i s/^SELINUX=.*$/SELINUX=disabled/ /etc/selinux/config
setenforce 0
