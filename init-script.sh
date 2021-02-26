#!/bin/bash
echo "im in the bash file"
sudo su - root
# Install AWS EFS Utilities
yum install -y amazon-efs-utils
# Mount EFS
mkdir /efs
efs_id="fs-3e677566:" #"${efs_id}"
mount -t efs $efs_id:/ /efs
# Edit fstab so EFS automatically loads on reboot
echo $efs_id:/ /efs efs defaults,_netdev 0 0 >> /etc/fstab

#sqllite, to work with the db, its either installed or should be installed by
#yum install -y sqlite3 libsqlite3-dev
#  yum list | grep sqlite and choose packet to install
