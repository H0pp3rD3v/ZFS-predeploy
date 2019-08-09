#!/bin/bash
echo "This file should be edited before being run"
sudo apt-add-repository universe
sudo apt update
echo 'Press Enter When Asked For Existing Password'
passwd
sudo apt install --yes openssh-server
sudo -i
apt install --yes debootstrap gdisk zfs-initramfs
sgdisk --zap-all /dev/disk/by-id/scsi-SATA_disk1
sgdisk -a1 -n1:24K:+1000K -t1:EF02 /dev/disk/by-id/scsi-SATA_disk1
sgdisk -n2:1M:+512M -t2:EF00 /dev/disk/by-id/scsi-SATA_disk1
sgdisk -n3:0:+512M -t3:BF01 /dev/disk/by-id/scsi-SATA_disk1
sgdisk -n4:0:0 -t4:BF01 /dev/disk/by-id/scsi-SATA_disk1
zpool create -o ashift=12 -d \
      -o feature@async_destroy=enabled \
      -o feature@bookmarks=enabled \
      -o feature@embedded_data=enabled \
      -o feature@empty_bpobj=enabled \
      -o feature@enabled_txg=enabled \
      -o feature@extensible_dataset=enabled \
      -o feature@filesystem_limits=enabled \
      -o feature@hole_birth=enabled \
      -o feature@large_blocks=enabled \
      -o feature@lz4_compress=enabled \
      -o feature@spacemap_histogram=enabled \
      -o feature@userobj_accounting=enabled \
      -O acltype=posixacl -O canmount=off -O compression=lz4 -O devices=off \
      -O normalization=formD -O relatime=on -O xattr=sa \
      -O mountpoint=/ -R /mnt \
      bpool /dev/disk/by-id/scsi-SATA_disk1-part3
zpool create -o ashift=12 \
      -O acltype=posixacl -O canmount=off -O compression=lz4 \
      -O dnodesize=auto -O normalization=formD -O relatime=on -O xattr=sa \
      -O mountpoint=/ -R /mnt \
      rpool /dev/disk/by-id/scsi-SATA_disk1-part4
zfs create -o canmount=off -o mountpoint=none rpool/ROOT
zfs create -o canmount=off -o mountpoint=none bpool/BOOT
zfs create -o canmount=noauto -o mountpoint=/ rpool/ROOT/ubuntu
zfs mount rpool/ROOT/ubuntu
zfs create -o canmount=noauto -o mountpoint=/boot bpool/BOOT/ubuntu
zfs mount bpool/BOOT/ubuntu
zfs create rpool/home
zfs create -o mountpoint=/root rpool/home/root
zfs create -o canmount=off rpool/var
zfs create -o canmount=off rpool/var/lib
zfs create rpool/var/log
zfs create rpool/var/spool
zfs create -o com.sun:auto-snapshot=false  rpool/var/cache
zfs create -o com.sun:auto-snapshot=false  rpool/var/tmp
chmod 1777 /mnt/var/tmp
zfs create rpool/opt
zfs create rpool/srv
zfs create -o canmount=off rpool/usr
zfs create rpool/usr/local
zfs create rpool/var/snap
zfs create rpool/var/lib/AccountsService
zfs create -o com.sun:auto-snapshot=false  rpool/var/lib/nfs
zfs create -o com.sun:auto-snapshot=false  rpool/tmp
chmod 1777 /mnt/tmp
debootstrap disco /mnt
zfs set devices=off rpool
echo TPZ-UXEN > /mnt/etc/hostname
echo "Please Populate mnt-etc-hosts"
echo "Please Populate mnt-etc-netplan-01-netcfg.yaml"
echo deb http://archive.ubuntu.com/ubuntu disco main universe >> /mnt/etc/apt/sources.list
echo deb-src http://archive.ubuntu.com/ubuntu disco main universe >> /mnt/etc/apt/sources.list
echo deb http://security.ubuntu.com/ubuntu disco-security main universe >> /mnt/etc/apt/sources.list
echo deb-src http://security.ubuntu.com/ubuntu disco-security main universe >> /mnt/etc/apt/sources.list
echo deb http://archive.ubuntu.com/ubuntu disco-updates main universe >> /mnt/etc/apt/sources.list
echo deb-src http://archive.ubuntu.com/ubuntu disco-updates main universe >> /mnt/etc/apt/sources.list
mount --rbind /dev  /mnt/dev
mount --rbind /proc /mnt/proc
mount --rbind /sys  /mnt/sys
chroot /mnt /bin/bash --login
ln -s /proc/self/mounts /etc/mtab
apt update
dpkg-reconfigure locales
dpkg-reconfigure tzdata
apt install --yes nano
apt install --yes --no-install-recommends linux-image-generic
apt install --yes zfs-initramfs
apt install dosfstools
mkdosfs -F 32 -s 1 -n EFI /dev/disk/by-id/scsi-SATA_disk1-part2
mkdir /boot/efi
echo PARTUUID=$(blkid -s PARTUUID -o value \
      /dev/disk/by-id/scsi-SATA_disk1-part2) \
      /boot/efi vfat nofail,x-systemd.device-timeout=1 0 1 >> /etc/fstab
mount /boot/efi
apt install --yes grub-efi-amd64-signed shim-signed
echo "Set Root Password"
passwd
cp ./zfs-import-bpool.service /etc/systemd/system/zfs-import-bpool.service
systemctl enable zfs-import-bpool.service
cp /usr/share/systemd/tmp.mount /etc/systemd/system
systemctl enable tmp.mount
addgroup --system lpadmin
addgroup --system sambashare
echo "Next Call should return zfs"
grub-probe /boot
update-initramfs -u -k all
echo "Please update etc-default-grub"
echo "Files Requiring Edits are within the mnt filesystem"
exit
