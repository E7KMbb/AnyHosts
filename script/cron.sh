work_dir=/sdcard/Android/Anyhosts
script_dir=${0%/*}

. $work_dir/Cron.ini

[ -f /data/adb/magisk/busybox ] && alias crond="/data/adb/magisk/busybox crond" && return 0

if [ $regular_update = "on" ]; then
   pid_text=$(ps -elf | grep "$script_dir/crontabs" | awk -F ' ' '{print $2}')
   for pid in ${pid_text[*]}; do
      kill -9 $pid &> /dev/null
   done
   rm -rf $script_dir/crontabs/root
   touch $script_dir/crontabs/root
   echo "$M $H $DOM $MO $DOW  sh $script_dir/functions.sh" >> $script_dir/crontabs/root
   chmod 777 $script_dir/crontabs/root
   crond -b -c $script_dir/crontabs
   echo "已开启定时更新服务"
elif [ $regular_update = "off" ]; then
   pid_text=$(ps -elf | grep "$script_dir/crontabs" | awk -F ' ' '{print $2}')
   for pid in ${pid_text[*]}; do
      kill -9 $pid &> /dev/null
   done
   echo "已关闭定时更新服务"
else
   echo "错误参数:$regular_update"
   echo "请输入on/off"
fi