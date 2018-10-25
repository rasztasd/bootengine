#!/bin/bash

read_key_from_dek_if_exists() {
  if [ -e "/sysroot/dek" ]; then
    info "Disk encryption key file is found."
    #TODO: remove export - variable should not be visible - variable is exported for debug purposes
    export KEY=$(cat /sysroot/dek)
    rc=0
    DEK_FROM_TPM="false"
  fi
}

if [ "$READ_DEK_FROM_TPM" = "true" ]; then
  info "Trying to read the disk encryption key from the TPM2.0"
  #TODO: remove export - variable should not be visible - variable is exported for debug purposes
  export KEY=$(LD_LIBRARY_PATH=/usr/local/lib /usr/local/bin/tpm2_nvread -x $NVRAM -a $NVRAM -L $PCRS)
  rc=$?
  if [ "$rc" != 0 ]; then
    info "Reading the disk encryption key from the TPM2.0 was unsuccessful. Trying to search for the disk encryption key file."
    read_key_from_dek_if_exists
  else
    DEK_FROM_TPM="true"
  fi
fi

[ -z "$KEY" ] && return 0

# mkdir -p /coreos_root
# mount /dev/disk/by-label/ROOT /coreos_root
mkdir -p /mnt
mount -t tmpfs inittemp /mnt
mkdir -p /mnt/lower
mkdir -p /mnt/rw

echo $KEY | cryptsetup luksOpen $DISK crypted_loop
mount /dev/mapper/crypted_loop /mnt/rw
mkdir -p /mnt/rw/work
mkdir -p /mnt/rw/var
mkdir -p /mnt/newroot
# mount --bind /coreos_root /mnt/lower
mount --rbind /sysroot /mnt/lower
mkdir -p /mnt/lower/usr
mount /dev/mapper/usr /mnt/lower/usr
mount -t overlay -o lowerdir=/mnt/lower,upperdir=/mnt/rw/root,workdir=/mnt/rw/work overlayfs-root /mnt/newroot
mount --bind /mnt/lower/usr /mnt/newroot/usr
mount --bind /mnt/rw/var /mnt/newroot/var
# mount /dev/disk/by-label/EFI-SYSTEM /mnt/newroot/boot

# if [ $DEK_FROM_TPM = "true" ]; then
#   /coreos_root/tpm2/bin/tpm2_pcrextend 0:sha1=$(echo asdf | sha1sum | cut -f 1 -d ' ')
#   /coreos_root/tpm2/bin/tpm2_pcrextend 0:sha256=$(echo asdf | sha256sum | cut -f 1 -d ' ')
# fi
mount --rbind /mnt/newroot /sysroot
