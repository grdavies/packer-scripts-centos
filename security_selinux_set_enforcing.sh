#!/usr/bin/env bash
#
# Set SELinux to enforcing mode
#

sed -i s/^SELINUX=.*$/SELINUX=enforcing/ /etc/selinux/config
