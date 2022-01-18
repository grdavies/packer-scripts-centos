#!/usr/bin/env bash
#
# Enable firewalld
#

# Ensure firewalld is installed
yum install -y firewalld

# Enable the firewalld service to start automatically
systemctl enable firewalld

# Start firewalld
systemctl start firewalld
