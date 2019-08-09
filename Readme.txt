1.

Run zfs partition script in pre install linux environment

IMPORTANT
edit the script to suit your disk id's before execution

2.

You will need to setup the network config and hosts files namually

hosts example;

Add a line:
127.0.1.1       HOSTNAME
or if the system has a real name in DNS:
127.0.1.1       FQDN HOSTNAME

netcfg.yaml example;

network:
  version: 2
  ethernets:
    NAME:
      dhcp4: true


3.
Update Grub Configuration for zfs support

Set: GRUB_CMDLINE_LINUX="root=ZFS=rpool/ROOT/ubuntu"

Reccommened (easy grub debugging)

Comment out: GRUB_TIMEOUT_STYLE=hidden
Set: GRUB_TIMEOUT=5
Below GRUB_TIMEOUT, add: GRUB_RECORDFAIL_TIMEOUT=5
Remove quiet and splash from: GRUB_CMDLINE_LINUX_DEFAULT
Uncomment: GRUB_TERMINAL=console

4.
Run the postpartition script

The system will restart when finished

5.
Run the firstboot script

You Will need to update the netcfg file again

example;

network:
  version: 2
  renderer: NetworkManager

6.
Reboot system

Update the default grub file to restore Graphical Boot (undo easy debugging)

Uncomment: GRUB_TIMEOUT_STYLE=hidden
Add quiet and splash to: GRUB_CMDLINE_LINUX_DEFAULT
Comment out: GRUB_TERMINAL=console

Run Cleanup script


IGNORE ALL OSPROBER ERRORS DURING PROCESS
