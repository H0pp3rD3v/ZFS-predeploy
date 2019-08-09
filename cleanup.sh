#!/bin/bash
sudo zfs destroy bpool/BOOT/ubuntu@install
sudo zfs destroy rpool/ROOT/ubuntu@install
sudo usermod -p '*' root
sudo update-grub
