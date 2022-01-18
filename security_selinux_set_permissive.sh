#!/usr/bin/env bash
#
# Set SELinux to permissive mode
#

sed -i s/^SELINUX=.*$/SELINUX=permissive/ /etc/selinux/config
setenforce 0
