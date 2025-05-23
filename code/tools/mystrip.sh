#!/bin/sh

strip -s $1
ARCH=`dd if=$1 bs=1  count=1 skip=4 2>/dev/null | xxd -p`
OFFSET=`readelf -Wa $1 | grep LOAD | awk '{print $2}' | tail -1`
SIZE=`readelf -Wa $1 | grep LOAD | awk '{print $5}' | tail -1`

TSIZE=$(($OFFSET + $SIZE))

if [ "$ARCH" = "02" ]
then
    echo "Patching 64bits ELF"
    dd if=/dev/zero of=$1 bs=1 count=2 seek=$((0x3c)) conv=notrunc 2> /dev/null
    dd if=/dev/zero of=$1 bs=1 count=8 seek=$((0x28)) conv=notrunc 2> /dev/null
    dd if=/dev/zero of=$1 bs=1 count=2 seek=$((0x3e)) conv=notrunc 2> /dev/null
else
    echo "Patching 32 bits ELF"
    dd if=/dev/zero of=$1 bs=1 count=2 seek=$((0x30)) conv=notrunc 2> /dev/null
    dd if=/dev/zero of=$1 bs=1 count=4 seek=$((0x20)) conv=notrunc 2> /dev/null
    dd if=/dev/zero of=$1 bs=1 count=2 seek=$((0x32)) conv=notrunc 2> /dev/null    
fi

echo "+ Truncating file at $(($SIZE))"
truncate $1 -s $(($SIZE))
   

