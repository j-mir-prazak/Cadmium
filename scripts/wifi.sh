#!/bin/bash
set -x
set -e
dmesg --console-off # make kernel shut up


# try finding current device in cadmium tree
CADMIUMROOT="/CdFiles"
TARGET=none
COMPATIBLE="$(cat /sys/firmware/devicetree/base/compatible)"
for x in $(find $CADMIUMROOT/board/* -type d -printf '%f\n'); do
	try=$(echo $COMPATIBLE | grep $x) || true
	if [ -n "$try" ]; then
		echo "Found device from compatible string: $x"
		TARGET="$x"
	fi
done

if [ $TARGET = none ]; then
	echo "Failed to autodetect device, bailing out"
	exit 1
fi

. $CADMIUMROOT/board/$TARGET/boardinfo
. $CADMIUMROOT/baseboard/$BASEBOARD/boardinfo
echo "$SOC $BOARD $BASEBOARD"

if [ "$BASEBOARD" = "trogdor" ]; then
	make -j$(nproc) -C /CdFiles/qmic install prefix=/usr
	echo qmic >> /CdFiles/installed_progs
	make -j$(nproc) -C /CdFiles/qrtr install prefix=/usr
	echo qrtr >> /CdFiles/installed_progs
	make -j$(nproc) -C /CdFiles/rmtfs install prefix=/usr
	echo rmtfs >> /CdFiles/installed_progs


	## making it stick  ##
	######################
	systemctl unmask rmtfs
	systemctl enable rmtfs
	######################


	systemctl start rmtfs # TODO: make this work on voidlinux
	sleep 10 # wait for ath10k_snoc to do its thing
fi

nmcli device wifi rescan
sleep 4 # wait for wifi networks
nmtui connect

# try finding emmc
