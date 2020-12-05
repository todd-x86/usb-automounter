#!/bin/bash
# USB Automounter
# by Todd Suess
# 
# =====================
# I wrote this because udevd wasn't working correctly for my Debian NAS,
# and I'm too lazy to write a C program with something like libudev.
# I'll do better next time.  This just helped get me out of a bind. :)
# =====================

if [ "${USER}" != "root" ]; then
	echo "ERROR: you must run automounter.sh as 'root'"
	exit 1
fi
echo "Waiting for devices..."
while read -r line; do
	# Mount USB
	if [[ "${line}" =~ "Attached SCSI removable disk" ]]; then
		# NOTE: This only mounts first partition
		dev_blk=$(echo "${line}" | sed -e 's/^.*\[\(.*\)\] Attached.*$/\1/g')
		dev_idx=1
		dev_id="${dev_blk}${dev_idx}"
		echo "New mount - finding device block..."
		# NOTE: This probably doesn't need to be here,
		#       just a sanity check for correct partition up to 10 spins
		#       so this doesn't run wild.
		while [ ! -e "/dev/${dev_id}" ] && [ "${dev_idx}" != "10" ]; do
			dev_idx=$((dev_idx+1))
			dev_id="${dev_blk}${dev_idx}"
		done
		if [ -e "/dev/${dev_id}" ]; then
			echo "Mounting ${dev_id}..."
			mkdir -p /media/${dev_id} &>/dev/null
			/usr/bin/mount --make-shared /dev/${dev_id} /media/${dev_id}
		fi
		echo "Waiting for more..."
	elif [[ "${line}" =~ "USB disconnect, device number" ]]; then
		# Check /media/ directory for bad mounts by checking /dev/
		# NOTE: don't put any non-device "sd*" folders under /media/ otherwise you may not want to use this...
		for mnt in $(find /media/ -maxdepth 1 -type d -name "sd*"); do
			mnt_id=$(basename "${mnt}")
			if [ ! -e "/dev/${mnt_id}" ]; then
				echo "Removing mount ${mnt_id}..."
				umount /dev/${mnt_id} && rm -r /media/${mnt_id}
			fi
		done
	fi
done < <(tail -f /var/log/messages)
