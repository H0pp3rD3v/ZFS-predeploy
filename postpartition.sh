#!/bin/bash
sudo -i
chroot /mnt /bin/bash --login
update-grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi \
      --bootloader-id=ubuntu --recheck --no-floppy
echo "Confirm ZFS module Installed"
ls /boot/grub/*/zfs.mod
umount /boot/efi
zfs set mountpoint=legacy bpool/BOOT/ubuntu
echo bpool/BOOT/ubuntu /boot zfs \
      nodev,relatime,x-systemd.requires=zfs-import-bpool.service 0 0 >> /etc/fstab
zfs set mountpoint=legacy rpool/var/log
echo rpool/var/log /var/log zfs nodev,relatime 0 0 >> /etc/fstab
zfs set mountpoint=legacy rpool/var/spool
echo rpool/var/spool /var/spool zfs nodev,relatime 0 0 >> /etc/fstab
zfs set mountpoint=legacy rpool/var/tmp
echo rpool/var/tmp /var/tmp zfs nodev,relatime 0 0 >> /etc/fstab
zfs set mountpoint=legacy rpool/tmp
echo rpool/tmp /tmp zfs nodev,relatime 0 0 >> /etc/fstab
zfs snapshot bpool/BOOT/ubuntu@install
zfs snapshot rpool/ROOT/ubuntu@install
exit
mount | grep -v zfs | tac | awk '/\/mnt/ {print $3}' | xargs -i{} umount -lf {}
zpool export -a
reboot
