#!/usr/bin/env bash
#
# Run YUM Update & Upgrade
#

set -o errexit

yum update -y
yum upgrade -y
