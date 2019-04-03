#!/bin/bash

#ugly script with no functions. Will only run once.

MOUNT_OPTIONS="defaults"

#volume 1 (metric)
echo "calling parted, label"
parted /dev/sdc mklabel gpt
echo "calling parted mkpart"
parted /dev/sdc mkpart primary 0.0TB 4.00TB
echo "formatting"
mkfs.ext4 -F /dev/sdc

cd /
mkdir metric_storage
echo "mounting volume"
mount /dev/sdc /metric_storage

UUID=`blkid -u filesystem /dev/sdc|awk -F "[= ]" '{print $3}'`
LINE="UUID=${UUID}\t/metric_storage\text4\t${MOUNT_OPTIONS}\t0\t0"
echo -e "${LINE}" >> /etc/fstab

#volume 2 (backup)
echo "calling parted, label"
parted /dev/sdd mklabel gpt
echo "calling parted mkpart"
parted /dev/sdd mkpart primary 0.0TB 4.00TB
echo "formatting"
mkfs.ext4 -F /dev/sdd

cd /
mkdir backup_storage
echo "mounting volume"
mount /dev/sdd /backup_storage

UUID=`blkid -u filesystem /dev/sdd|awk -F "[= ]" '{print $3}'`
LINE="UUID=${UUID}\t/backup_storage\text4\t${MOUNT_OPTIONS}\t0\t0"
echo -e "${LINE}" >> /etc/fstab

#volume 3 (shared)
echo "calling parted, label"
parted /dev/sde mklabel gpt
echo "calling parted mkpart"
parted /dev/sde mkpart primary 0.0TB 2.00TB
echo "formatting"
mkfs.ext4 -F /dev/sde

cd /
mkdir shared_storage
echo "mounting volume"
mount /dev/sde /shared_storage

UUID=`blkid -u filesystem /dev/sde|awk -F "[= ]" '{print $3}'`
LINE="UUID=${UUID}\t/shared_storage\text4\t${MOUNT_OPTIONS}\t0\t0"
echo -e "${LINE}" >> /etc/fstab



#to avoid chicken and egg, create the dynatrace user first
groupadd dynatrace
useradd -g dynatrace -s /sbin/nologin dynatrace

#nfs mount
yum -y install nfs-utils
mkdir /mnt/dynatrace-backup

#Replace <NFS-IP> with IP address of NFS server, vnet peering must be in place.
LINE="10.1.0.7:/mnt/dynatrace-backup\t/mnt/dynatrace-backup\tnfs\tdefaults\t0\t0" 
echo -e "${LINE}" >> /etc/fstab
mount -av
chown dynatrace:dynatrace /mnt/dynatrace-backup


#create softlink to keep structure identical to old node 1
cd /mnt
ln -s /backup_storage backup_storage

#create directory structure for all servers
cd /shared_storage
mkdir elastic_storage
mkdir session
mkdir transaction_storage

# fix to sort out old messy volumes
cd /backup_storage
mkdir agents
cd /var/opt
mkdir dynatrace-managed 
ln -s /backup_storage/agents agents 
cd /backup_storage
chown dynatrace:dynatrace agents


