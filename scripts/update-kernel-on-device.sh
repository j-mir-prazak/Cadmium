#!/bin/bash

DIR=$(dirname $(realpath $0))

if [[ -z $1 ]]; then
    echo "NO DEVICE SPECIFIED."
    exit 1;
fi

DEVICE="$1"

echo $DIR
echo $DEVICE

dd if=$DIR/vmlinux.kpart of=$DEVICEp1
dd if=$DIR/vmlinux.kpart.p2 of=$DEVICEp2

mkdir -p /tmp/mount_update
mount /dev/$DEVICEp3 /tmp/mount_update

dd if=$DIR/oxide.kpart of=/tmp/mount_update/oxide.kpart
cp -r $DIR/modules /tmp/mount_update/

umount /tmp/mount_update
