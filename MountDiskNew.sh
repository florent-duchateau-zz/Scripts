#!/bin/bash

#ugly script with no functions. Will only run once.

MOUNT_OPTIONS="noatime,nodiratime,nodev,noexec,nosuid,nofail"

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
LINE="UUID=${UUID}      /dev/sdc/       ext4    ${MOUNT_OPTIONS}        1 2"
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
LINE="UUID=${UUID}      /dev/sdd/       ext4    ${MOUNT_OPTIONS}        1 2"
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
LINE="UUID=${UUID}      /dev/sde/       ext4    ${MOUNT_OPTIONS}        1 2"
echo -e "${LINE}" >> /etc/fstab