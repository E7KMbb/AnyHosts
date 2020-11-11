# This script will be executed during uninstallation, you can write your custom uninstall rules
hosts_dir=/data/adb/modules/hosts
rm -rf /sdcard/AnyHosts
if [ -d $hosts_dir ];then
   touch $hosts_dir/remove
fi
