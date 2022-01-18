#!/usr/bin/env bash
#
# Disable firewalld
#

# Stop firewalld
systemctl stop firewalld

# Disable the firewalld service to start automatically
systemctl disable firewalld
