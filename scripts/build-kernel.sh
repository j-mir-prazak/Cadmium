#!/bin/bash
# script to build new kernel and modules only

CADMIUMROOT=$(dirname $(dirname $(realpath $0)))

source $CADMIUMROOT/config
source $CADMIUMROOT/board/$TARGET/boardinfo
source $CADMIUMROOT/baseboard/$BASEBOARD/boardinfo

set -e

sleep 1 # let's give user time if they commit a typo

KERNELLINK=""
if [[ ! -z $1 ]]; then 
    KERNELLINK="$1"
fi



$CADMIUMROOT/kernel/build "$KERNELLINK"

$CADMIUMROOT/bootfw/$BOOTFW/package

mkdir -p $CADMIUMROOT/tmp/modules
make -C $CADMIUMROOT/tmp/linux-$ARCH INSTALL_MOD_PATH=$CADMIUMROOT/tmp/modules modules_install

