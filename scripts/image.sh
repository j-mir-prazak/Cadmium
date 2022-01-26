#!/bin/bash


if [ -n "$2" ]; then # if $2 is set, it means that user wants a file
	echo "Making file $1 with size of $2"
	IMG=$(realpath $1)
	fallocate $IMG -l $2
	DEVICE=$(losetup -f)
	losetup $DEVICE $IMG

    echo "LOOP: $DEVICE"
	KERNPART=${DEVICE}p1
	KERNPART_B=${DEVICE}p2
	ROOTPART=${DEVICE}p3
else
    exit 1
fi


sync

# make partition table
parted --script $DEVICE mklabel gpt # cgpt dislikes if i don't do that, so do that

# now this is _real_ partition table
# 73728 comes from: size of kernel partition(65536) + beginning of kernel partition(8192)
# 139264 comes from: size of B kernel partition(65536) + beginning of B kernel partition(73728)

SWAPSIZE=0 
if [[ ! -z $3 ]]; then
    SWAPSIZE=$3
fi
SWAPSIZE_BLOCKS=$(( $SWAPSIZE * ( 1000 * 1000 ) / 512 ))
#echo "swapblocks: $SWAPSIZE_BLOCKS"
cgpt create $1
cgpt add -i 1 -t kernel -b 8192		-s 65536            -l SDKernelA -S 1 -T 2 -P 10 $DEVICE
cgpt add -i 2 -t kernel -b 73728    -s 65536            -l SDKernelB -S 0 -T 2 -P 5 $DEVICE

if [[ $SWAPSIZE -gt 0 ]] ; then
    echo "Adding swap."
    ROOTFSSIZE_BLOCKS=$(expr $(cgpt show $1 | grep 'Sec GPT table' | awk '{print $1}') - $(( 139264 + $SWAPSIZE_BLOCKS ))  )
    cgpt add -i 3 -t data   -b 139264                              -s $ROOTFSSIZE_BLOCKS -l Root $DEVICE
    cgpt add -i 4 -t data   -b $(( 139264 + $ROOTFSSIZE_BLOCKS ))  -s $(expr $(cgpt show $1 | grep 'Sec GPT table' | awk '{print $1}') - $(( 139264 + $ROOTFSSIZE_BLOCKS ))	)  -l Swap $DEVICE
else
    echo "Skipping swap."
    cgpt add -i 3 -t data -b 139264		-s $(expr $(cgpt show $1 | grep 'Sec GPT table' | awk '{print $1}') - 139264) -l Root $DEVICE
fi



sync

partx -a $DEVICE >/dev/null 2>&1 || true # fails if something else added partitions 
losetup -d $DEVICE
