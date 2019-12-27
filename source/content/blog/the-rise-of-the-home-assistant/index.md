---
title: "The Rise of the Home Assistant"
date: 2019-12-25T04:19:52Z
draft: true
---

Install hass.io
https://www.home-assistant.io/hassio/installation/

```shell
WORKDIR="$(mktemp --directory)"
curl -o ${WORKDIR}/hassos_rpi4-64-3.7.img.gz -L https://github.com/home-assistant/hassos/releases/download/3.7/hassos_rpi4-64-3.7.img.gz
gunzip ${WORKDIR}/hassos_rpi4-64-3.7.img.gz
SD_CARD="/dev/sde"
mount | grep $SD_CARD | awk '{ print $3 }' | xargs -L1 -r umount
sudo dd bs=4M if=${WORKDIR}/hassos_rpi4-64-3.7.img of="${SD_CARD}" conv=fsync

```

https://github.com/home-assistant/hassos/blob/dev/Documentation/network.md#wireless-wpapsk

```shell
MY_SSID=xxxx
MY_WLAN_SECRET_KEY=xxxx


CONFIGMNT="$(mktemp --directory)"
sudo mount "$(sudo blkid | grep "^${SD_CARD}" | grep 'LABEL="hassos-boot"' | awk -F ':' '{ print $1; exit }')" "${CONFIGMNT}"
sudo mkdir -p ${CONFIGMNT}/CONFIG/network
sudo tee ${CONFIGMNT}/CONFIG/network/my-network << EOF
[connection]
id=my-network
uuid=$(uuidgen)
type=802-11-wireless

[802-11-wireless]
mode=infrastructure
ssid=${MY_SSID}
# Uncomment below if your SSID is not broadcasted
#hidden=true

[802-11-wireless-security]
auth-alg=open
key-mgmt=wpa-psk
psk=${MY_WLAN_SECRET_KEY}

[ipv4]
method=auto

[ipv6]
addr-gen-mode=stable-privacy
method=auto
EOF
sudo umount ${CONFIGMNT}
```

/dev/ttyAMA0





https://github.com/home-assistant/hassio-addons/issues/947




## Make the SD Card
WORKDIR="$(mktemp --directory)"
curl -o ${WORKDIR}/rootfs.img.xz -L http://cdimage.ubuntu.com/releases/19.10.1/release/ubuntu-19.10.1-preinstalled-server-arm64+raspi3.img.xz
unxz ${WORKDIR}/rootfs.img.xz
ls -lah ${WORKDIR}/rootfs.img
SD_CARD="/dev/sde"
mount | grep $SD_CARD | awk '{ print $3 }' | xargs -L1 -r sudo umount
sudo dd bs=4M if=${WORKDIR}/rootfs.img of="${SD_CARD}" conv=fsync

## Move the root partition to the usb drive


USB_DRIVE="/dev/sdh"
mount | grep $USB_DRIVE | awk '{ print $3 }' | xargs -L1 -r sudo umount
dd if=${SD_CARD}2 of=$USB_DRIVE bs=4M


USB_DRIVE="/dev/sdh"
mount | grep $USB_DRIVE | awk '{ print $3 }' | xargs -L1 -r sudo umount
sudo mkfs.xfs -L "system-root" -f $USB_DRIVE
USB_MNT="$(mktemp --directory)"
sudo mount $USB_DRIVE $USB_MNT

SD_CARD="/dev/sde"
mount | grep $SD_CARD | awk '{ print $3 }' | xargs -L1 -r sudo umount
SD_MNT_BOOT="$(mktemp --directory)"
SD_MNT_ROOT="$(mktemp --directory)"
sudo mount ${SD_CARD}1 $SD_MNT_BOOT
sudo mount ${SD_CARD}2 $SD_MNT_ROOT
sudo setenforce 0
sudo rsync -axHAWXS --numeric-ids --info=progress2  ${SD_MNT_ROOT}/ $USB_MNT
sudo setenforce 1

sudo blkid -c /dev/null ${SD_CARD}*
sudo blkid -c /dev/null ${USB_DRIVE}*




# enable bluetooth
sudo sed -i 's/include nobtcfg.txt/include btcfg.txt/' $SD_MNT_BOOT/syscfg.txt

# setup to boot from usb
sudo sed -i 's/root=LABEL=writable/root=LABEL=system-root/' $SD_MNT_BOOT/btcmd.txt $SD_MNT_BOOT/nobtcmd.txt
sudo sed -i 's/rootfstype=ext4/rootfstype=xfs/' $SD_MNT_BOOT/btcmd.txt $SD_MNT_BOOT/nobtcmd.txt
sudo sed -i "/LABEL=writable/c\LABEL=system-root       /               xfs     defaults        0       0"  $USB_MNT/etc/fstab


# Fix storage quirks
sudo sed -i 's/^/usb-storage.quirks=152d:1561:u /' $SD_MNT_BOOT/btcmd.txt $SD_MNT_BOOT/nobtcmd.txt

# workaround kernel bug with usb
#sudo tee -a $SD_MNT_BOOT/usercfg.txt <<EOF
#total_mem=3072
#EOF


mount | grep $SD_CARD | awk '{ print $3 }' | xargs -L1 -r sudo umount
mount | grep $USB_DRIVE | awk '{ print $3 }' | xargs -L1 -r sudo umount

sudo sfdisk --delete ${SD_CARD} 2

sudo mount ${SD_CARD}1 $SD_MNT_BOOT
sudo tee $SD_MNT_BOOT/network-config <<EOF
version: 2
ethernets:
  eth0:
    dhcp4: true
    optional: true
wifis:
  wlan0:
    dhcp4: true
    optional: true
    access-points:
      ssid:
        password: "password"
EOF

sudo tee $SD_MNT_BOOT/meta-data <<EOF
# This is the meta-data configuration file for cloud-init. Typically this just
# contains the instance_id. Please refer to the cloud-init documentation for
# more information:
#
# https://cloudinit.readthedocs.io/

instance_id: cloud-image
EOF

sudo tee $SD_MNT_BOOT/user-data <<EOF
#cloud-config

# Enable password authentication with the SSH daemon
ssh_pwauth: true

# On first boot, set the (default) ubuntu user's password to "ubuntu" and
# expire user passwords
chpasswd:
  expire: false
  list:
  - ubuntu:ubuntu


## Update apt database and upgrade packages on first boot
#package_update: true
#package_upgrade: true
EOF
mount | grep $SD_CARD | awk '{ print $3 }' | xargs -L1 -r sudo umount