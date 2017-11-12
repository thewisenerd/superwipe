#!/bin/bash

do_shell () {
	adb shell "$@"
}

delete_recursive () {
	do_shell rm -rf "$1"
}

ui_print () {
	echo "$@"
}

ui_print "force umount partitions+"
do_shell umount -f /dev/block/mtdblock3
do_shell umount -f /dev/block/mtdblock4
do_shell umount -f /dev/block/mtdblock5
ui_print "force umount partitions-"

ui_print "nand_recovery+";
FE="/tmp/flash_erase"
adb push "flash_erase" $FE;
do_shell chmod 777 $FE

ui_print "recovering boot"
do_shell $FE "-N" "/dev/mtd/mtd2" "0" "0"

ui_print "recovering system"
do_shell $FE "-N" "/dev/mtd/mtd3" "0" "0"

ui_print "recovering cache"
do_shell $FE "-N" "/dev/mtd/mtd4" "0" "0"

ui_print "recovering userdata"
do_shell $FE "-N" "/dev/mtd/mtd5" "0" "0"
ui_print "nand_recovery-"

ui_print "sd-ext+"
if do_shell "ls" "/dev/block" | grep --quiet mmcblk0p2 ; then
	ui_print "fmt ext4"
	do_shell "/sbin/mke2fs" "-T" "ext4" "/dev/block/mmcblk0p2"

	ui_print "enable writeback"
	do_shell "/sbin/tune2fs" "-o" "journal_data_writeback" "/dev/block/mmcblk0p2"

	ui_print "disable journaling"
	do_shell "/sbin/tune2fs" "-O" "^has_journal" "/dev/block/mmcblk0p2"
else
	ui_print "no sd-ext"
fi
ui_print "sd-ext-"
