#!/bin/bash

# Change le Kernel par défaut sur OVH

apt-get update -y && apt-get upgrade -y && apt-get install linux-image-generic -y
mv /etc/grub.d/06_OVHkernel /etc/grub.d/25_OVHkernel
update-grub
shutdown -r now
