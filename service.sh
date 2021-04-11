#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode
work_dir=/sdcard/Android/AnyHosts
wait_count=0
until [ $(getprop sys.boot_completed) -eq 1 ] && [ -d "$work_dir" ]; do
  sleep 2
  wait_count=$((${wait_count} + 1))
  if [ ${wait_count} -ge 100 ] ; then
    exit 0
  fi
done

nohup $MODDIR/script/functions.sh