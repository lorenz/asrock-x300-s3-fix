# ASRock DeskMini X300 S3 suspend fix

[Blog post](https://lorenz.brun.one/enabling-s3-sleep-on-x300/) with much more in-depth information
about this.

## Requirements

- A Cezanne-based APU (Ryzen 5X00G) (unless you want to be a guinea pig)
- A Linux-based operating system
- nix installed (note NixOS is not necessary)
- Latest firmware at the time of writing (1.70)

## :warning: WARNINGS

1. This is unsupported by both the vendor (ASRock) and me. I am not responsible for dead hardware or
   eaten cats. And depending on your jurisdiction it might void your warranty.
2. Any change to firmware settings can change the underlying ACPI tables. Since the patched one is
   not taken from the firmware you then have an inconsistent set of ACPI tables loaded which can
   lead to unpredictable behavior and in extreme cases even hardware damage. The only "safe" way to
   do this is to never change firmware settings or update the firmware after you've injected the
   patch. Otherwise you need to remove the hack first, change the settings and then redo the whole
   procedure.
3. This is only confirmed to work on Cezanne-based APUs (so the Ryzen 5x00G series) with TSME
   disabled. It might very well not work with other APUs.
4. It only works if your operating system supports overriding ACPI tables. I don't know how to do
   that on Windows and have never tested it.

## Instructions

```sh
cd /path/to/this/repo
sudo cp /sys/firmware/acpi/tables/SSDT1 ssdt1.aml
sudo cp /sys/firmware/acpi/tables/SSDT6 ssdt6.aml
sudo cp /sys/firmware/acpi/tables/DSDT dsdt.aml
sudo chown $(id -un) *.aml
chmod 640 *.aml
./mkoverride.sh
```

After that you'll have a file named `acpi_dsdt_override.cpio` in the repository root. Prepending
this file to your initramfs is distro-specific.

### NixOS
Add `boot.initrd.prepend = [ "${./acpi_dsdt_override.cpio}" ];` to your configuration.

### Debian-based distros
`prepend_earlyinitramfs` in a initramfs-tools hook can be used, see
[this file](https://github.com/naftulikay/thinkpad-yoga-3rd-gen-acpi/blob/88f47bf0922bcbb85e946fabcb8fb86cdcf40b51/etc/initramfs-tools/hooks/acpi-override)
for reference.

### Arch Linux-based distros

Copy `acpi_dsdt_override.cpio` to `/boot`.

#### with GRUB

Add this line to your grub configuration file `/etc/default/grub`:

```
GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi_dsdt_override.cpio"
```

then regenerate grub.cfg:

```sh
grub-mkconfig -o /boot/grub/grub.cfg
```

#### with systemd-boot

Add this line **before** any other `initrd` entries in the desired `/boot/loader/entries/*.conf`:

```
initrd /acpi_dsdt_override.cpio
```

Full example:

```
title Arch Linux
linux /vmlinuz-linux
initrd /acpi_dsdt_override.cpio
initrd /initramfs-linux.img
options cryptdevice=UUID=57e23788-b609-4489-8025-15dc65062833:cryptlvm cryptkey=/dev/disk/by-label/KEYS:ext2:/disk_work.key root=/dev/volgrp/root splash amd_pstate=passive
```
