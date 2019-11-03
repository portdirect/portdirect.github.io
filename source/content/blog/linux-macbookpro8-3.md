---
title: 'Linux on the 17" MacBook Pro 8.3'
date: 2019-11-01T15:13:39-05:00
draft: false
---

Sometimes things seem like they were more natural in the past. I used to run a variety of distros' on my old Late 2011 17" Apple Macbook Pro with little hassle. I'm pretty convinced this old thing is one of the best machines ever made for doing serious work on; a fantastic 16:10 Screen, an excellent keyboard, and with no vents on the bottom to inhale cat hair. GPU issues aside, its been solid, so perhaps the lack of bottom vents wasn't such a good idea after all. Anyway, though maybe some rose-tinted spectacles are in play, I'm pretty sure I used to click a few buttons and get on with life, but alas, this is not the case anymore.

In my day job, we pretty much exclusively use Ubuntu Server, though I've never enjoyed the out of the box experience with Ubuntu Desktop. And after some half-hearted efforts find it too much of a continual burden to keep Gnome relatively unmolested by Shuttleworth's lackey's whims to bother. Besides, Fedora lets me play with new shiny things long before they ever become a problem that threatens my ability to have a lovely lazy weekend. So without further ado, the following describes the saga of getting Fedora 31 up and running on this old machine, and I'll try to keep it updated as things progress.


### Make the install media

I've got a beautiful new shiny MacBook, one of the new ones with a terrible keyboard and the touch bar that seems to be designed solely to cause me to accidentally rest my finger on the `esc` section at the most inopportune times, courtesy of my employer. I thought this would be a simple affair, download a Fedora ISO open disc utility, connect a plethora of dongles, attach a USB key, and hit buttons until i get a fresh shiny bootable media for the 17" MBP. However, the lords of Cupertino had different ideas, and by MacOS 10.15 disc utility tries to inspect the contents of iso's before `restoring` them to a USB key and promptly vomits over the mear concept of an unrecognized filesystem. A quick browse turns up [Balena Etcher](https://www.balena.io/etcher/), and we are back in business.


### Boot into live media and install to internal SSD

Once the USB key is inserted into the Laptop, it's a simple case of booting the computer holding down the `ctrl` key, and off we go. As I'm not interested in keeping MacOS on this thing, from here out, things could be pretty straight forward, but I like making things just that little bit harder for myself. As a result, I use the same technique I've used for a bit, born out of laziness, to get an XFS root filesystem, as I much prefer this to EXT4. This bias is as back in the day we used to have nightmares with a load of Docker containers, using the original OverlayFS implementation consuming inodes like its very existence depends upon it. The trick I use is to deploy with Anaconda choosing to manage the whole first disc with LVM, encrypting the Volume Group that contains the root partition, starting the installation, and then canceling it as soon as it's finished creating the partition layout and file systems to use. I then go back to square one, but this time select advanced partitioning and consume the devices that have been created for me, merely changing EXT4 to XFS and proceeding. Once complete I shut down the machine, remove the USB key, and power it back on.

### Get Wifi working

I'm sure that with Fedora ~26 this post would have ended above, but upon powering back up and going through the Gnome setup process, I'm left with no working WIFI. Ok, lets see what's going on here:

```shell
$ sudo lspci | grep Network
03:00.0 Network controller: Broadcom Inc. and subsidiaries BCM4331 802.11a/b/g/n (rev 02)
```


So we have a Broadcom BCM4331 here, a quick search turns up we have a couple of different options:

1. Find the windows driver, and shim it to work with Linux.
2. Compile and load the appropirate kernel module against the running kernel
3. Use [DKMS](https://en.wikipedia.org/wiki/Dynamic_Kernel_Module_Support).

Lets start by looking at option 1, it's horrible and gross, not in a late 90's *Micro$oft SUX!* kinda way, but more in a [Elephant and Pig](https://southpark.cc.com/clips/103344/four-assed-monkey) kinda way. So lets stop looking at it, seek counseling, and remove it from the option list.
Option 2 is pretty great, but would break when we change kernel version, we could work round this with a systemd unit on startup or similar that watches for breakage and fixes it, but thats a hack to far, even for me. So looks like option 3 is where we want to be focusing our attention. Luckily we don't need to focus for too long, as the nice folk over at [UnitedRPMs](https://unitedrpms.github.io/) have done all the hard work, and made us a RPM to use for this, so lets get that set up and installed:

```bash
rpm --import https://raw.githubusercontent.com/UnitedRPMs/unitedrpms/master/URPMS-GPG-PUBLICKEY-Fedora
dnf install -y https://github.com/UnitedRPMs/unitedrpms/releases/download/15/unitedrpms-$(rpm -E %fedora)-15.fc$(rpm -E %fedora).noarch.rpm
dnf install -y broadcom-wl-dkms
```

Did this work? Of course not, life is never that simple. When I did this, F31 was hot off the press and many mirrors had not updated yet, and I was hitting out of date ones for things like the kernel headers, so lets fix this by being explicit about what we want:

```bash
dnf install kernel-devel-$(uname -r | sed 's/.x86_64//')
dnf reinstall -y broadcom-wl-dkms
#Lets check the logs
cat /var/lib/dkms/broadcom-wl/*/log/make.log
```

After hitting a few mirrors we eventually get what we need, and things look a lot better. Somewhat giddy, it's time to reboot and see how things look. After rebooting, we have our wireless interface, and can see SSIDs out there, but connections fail. On any modern systemd based Linux, when things don't work, it's best to first head over to `journalctl` and see whats going on.

```
$ sudo journalctl -f
```




```
$ sudo lshw -c network
  *-network                 
       description: Ethernet interface
       product: NetXtreme BCM57765 Gigabit Ethernet PCIe
       vendor: Broadcom Inc. and subsidiaries
       physical id: 0
       bus info: pci@0000:02:00.0
       logical name: enp2s0
       version: 10
       serial: <REDACTED>
       capacity: 1Gbit/s
       width: 64 bits
       clock: 33MHz
       capabilities: pm msi msix pciexpress bus_master cap_list ethernet physical tp 10bt 10bt-fd 100bt 100bt-fd 1000bt 1000bt-fd autonegotiation
       configuration: autonegotiation=on broadcast=yes driver=tg3 driverversion=3.137 firmware=57765-v1.37 latency=0 link=no multicast=yes port=twisted pair
       resources: irq:16 memory:b0400000-b040ffff memory:b0410000-b041ffff
  *-network
       description: Wireless interface
       product: BCM4331 802.11a/b/g/n
       vendor: Broadcom Inc. and subsidiaries
       physical id: 0
       bus info: pci@0000:03:00.0
       logical name: wlp3s0
       version: 02
       serial: <REDACTED>
       width: 64 bits
       clock: 33MHz
       capabilities: pm msi pciexpress bus_master cap_list ethernet physical wireless
       configuration: broadcast=yes driver=wl0 driverversion=6.30.223.271 (r587334) ip=<REDACTED> latency=0 multicast=yes wireless=IEEE 802.11
       resources: irq:17 memory:b0600000-b0603fff
```