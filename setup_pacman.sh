#!/bin/sh

# make sure we are root
if [[ $EUID -ne 0 ]]; then
  echo "This must be run as root"
  exit 1
fi

cp systemd-boot-update.sh /usr/bin/systemd-boot-update
chmod 755 /usr/bin/systemd-boot-update
cp systemd-boot-update.hook /usr/share/libalpm/hooks/95_systemd_boot_update.hook

