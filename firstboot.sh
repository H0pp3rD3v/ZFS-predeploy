#!/bin/bash
zfs create rpool/home/itadmin
adduser itadmin
cp -a /etc/skel/.[!.]* /home/itadmin
chown -R itadmin:itadmin /home/itadmin
usermod -a -G adm,cdrom,dip,lpadmin,plugdev,sambashare,sudo itadmin
apt dist-upgrade --yes
apt install --yes ubuntu-desktop
echo "Update netplan for network manager"
for file in /etc/logrotate.d/* ; do
    if grep -Eq "(^|[^#y])compress" "$file" ; then
        sed -i -r "s/(^|[^#y])(compress)/\1#\2/" "$file"
    fi
done
