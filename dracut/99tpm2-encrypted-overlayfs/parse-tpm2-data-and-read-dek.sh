#!/bin/bash

for p in $(getargs coreos.tpm2-encrypted-overlayfs-options=); do
  export DISK=$(echo "$p" | cut -d ";" -f 1)
  export PCRS=$(echo "$p" | cut -d ";" -f 2)
  export NVRAM=$(echo "$p" | cut -d ";" -f 3)

    if [ -z "$PCRS" -o -z "$DISK" -o -z "$NVRAM" ]; then
      info "coreos.tpm2-encrypted-overlayfs-options is not set properly. Format: disk;pcrslist;nvramindex. Example: coreos.tpm2-encrypted-overlayfs-options=/dev/sda10;sha1:1,2,3;0x1800006"
    else
      info "coreos.tpm2-encrypted-overlayfs-options is set. Overlayfs DISK=$DISK PCRS=$PCRS NVRAM=$NVRAM."
      export READ_DEK_FROM_TPM="true"
    fi
done
