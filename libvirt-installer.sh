#!/bin/bash

# Found directions from video https://www.youtube.com/watch?v=_JTEsQufSx4&t=527
#
# - RisingPrism Guide: https://gitlab.com/risingprismtv/single-gpu-passthrough/-/wikis
# - OSX-KVM: https://github.com/kholia/OSX-KVM
# - VBIOS download: https://www.techpowerup.com/vgabios/

while getopts ':u:' opt; do
    case $opt in
        u)
            LOCAL_USER=${OPTARG}
            echo "Local user set to: ${OPTARG}"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

if [[ -z "$LOCAL_USER" ]]; then
    echo "Use parameter -u to define a user."
    exit 1
fi

pacman -S libvirt

sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet intel_iommu=on iommu=pt"/g' /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg

pacman -S virt-manager qemu vde2 ebtables iptables-nft nftables dnsmasq bridge-utils ovmf

sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf
sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g' /etc/libvirt/libvirtd.conf

echo 'log_filters="1:qemu"' >> /etc/libvirt/libvirtd.conf
echo 'log_outputs="1:file:/var/log/libvirt/libvirtd.log"' >> /etc/libvirt/libvirtd.conf

usermod -aG libvirt $LOCAL_USER
systemctl enable libvirtd

sed -i "s/#user = "libvirt-qemu"/user = "${LOCAL_USER}"/g" /etc/libvirt/qemu.conf
sed -i "s/#group = "libvirt-qemu"/group = "${LOCAL_USER}"/g" /etc/libvirt/qemu.conf

virsh net-autostart default
virsh net-start default
