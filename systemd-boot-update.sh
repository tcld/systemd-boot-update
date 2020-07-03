#!/bin/sh

machineid=$(cat /etc/machine-id)
esp=$(bootctl --print-esp-path)
boot=/boot

# uninstall all previously set up kernels for the currently booted system
remove() {
  cd "${esp}/${machineid}"
  for kernel in *; do
    # check if folder
    if [[ -d "$kernel" ]]; then
      kernel-install remove "$kernel"
    fi
  done
}

# fetch kernels from: /lib/modules/
add() {
  cd "/lib/modules"
  for kernel in *; do
    # check if name appears to be kernel version and if folder
    if [[ "$kernel" =~ ^[0-9]+\.[0-9]+\.[0-9]+.+$ && -d "$kernel" ]]; then
      # extract major.minor from $kernel
      majorminor=$(echo $kernel | sed --quiet "s/^\([0-9]\+\.[0-9]\+\)\..\+$/\1/p")
      for vmlinuz in "${boot}/vmlinuz-${majorminor}*"; do
        version=$(echo $vmlinuz | sed --quiet "s/^.\+-\([0-9].\+\)$/\1/p") # extract full version from $vmlinuz
        ucode=$(ls ${boot}/*-ucode.img) # locate microcode-updates
        init=$(ls ${boot}/init*-${version}.img) # locate initrd/initramfs-image

        kernel-install add "$kernel" $vmlinuz $ucode $init

        # NOTE: There can be only one entry per machine and kernel.
        # TODO: Do this first and modify the results? Would break auto-removal, though.
        #initfallback=$(ls ${boot}/init*-${version}-fallback.img)
        #kernel-install add "$kernel" $vmlinuz $ucode $init
      done
    fi
  done
}

# make sure we are root
if [[ $EUID -ne 0 ]]; then
  echo "systemd-boot-update must be run as root"
  exit 1
fi

remove
add

