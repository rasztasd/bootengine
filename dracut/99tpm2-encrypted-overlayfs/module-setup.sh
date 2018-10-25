#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

depends() {
    echo crypt
    return 0
}

check() {
    return 0
}

install() {
    # inst_multiple \
    #     /usr/local/bin/tpm2_pcrlist /usr/local/bin/tpm2_pcrextend /usr/local/bin/tpm2_nvread
    inst_multiple /usr/local/bin/*
    inst_multiple /usr/local/lib/*
    inst_multiple sha1sum sha256sum
    inst_hook cmdline 99 "$moddir/parse-tpm2-data-and-read-dek.sh"
    inst_hook pre-pivot 99 "$moddir/mount-overlay-fs.sh"
    inst_multiple \
        mount cryptsetup
}
