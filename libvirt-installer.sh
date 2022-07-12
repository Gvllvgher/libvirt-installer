#!/bin/bash

# Found directions from video https://www.youtube.com/watch?v=_JTEsQufSx4&t=527
#
# - RisingPrism Guide: https://gitlab.com/risingprismtv/single-gpu-passthrough/-/wikis
# - OSX-KVM: https://github.com/kholia/OSX-KVM
# - VBIOS download: https://www.techpowerup.com/vgabios/

#sudo pacman -Sy libvirt

sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet intel_iommu=on iommu=pt"/g' /etc/default/grub 
