#!/bin/bash

CADMIUMROOT=$(dirname $(dirname $(realpath $0)))

source $CADMIUMROOT/config
source $CADMIUMROOT/board/$TARGET/boardinfo
source $CADMIUMROOT/baseboard/$BASEBOARD/boardinfo 

mkdir -p $CADMIUMROOT/tmp/ship

cp -r $CADMIUMROOT/tmp/modules $CADMIUMROOT/tmp/ship/modules
cp $CADMIUMROOT/tmp/vmlinux.kpart $CADMIUMROOT/tmp/ship 
cp $CADMIUMROOT/tmp/vmlinux.kpart.p2 $CADMIUMROOT/tmp/ship
cp $CADMIUMROOT/tmp/oxide.kpart $CADMIUMROOT/tmp/ship/

cp $CADMIUMROOT/scripts/update-kernel-on-device.sh $CADMIUMROOT/tmp/ship/
