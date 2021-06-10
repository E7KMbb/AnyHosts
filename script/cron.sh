work_dir=/sdcard/Android/Anyhosts
script_dir=${0%/*}

# Local lang
locale=$(getprop persist.sys.locale|awk -F "-" '{print $1"_"$NF}')
[[ ${locale} == "" ]] && locale=$(settings get system system_locales|awk -F "," '{print $1}'|awk -F "-" '{print $1"_"$NF}')
if [ -e $script_dir/${locale}.ini ];then
   sh $script_dir/${locale}.ini
else
   sh $script_dir/en_US.ini
fi

sh $work_dir/Cron.ini

[ -f /data/adb/magisk/busybox ] && alias crond="/data/adb/magisk/busybox crond"

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
   echo "${LANG_CRON_ON}"
elif [ $regular_update = "off" ]; then
   pid_text=$(ps -elf | grep "$script_dir/crontabs" | awk -F ' ' '{print $2}')
   for pid in ${pid_text[*]}; do
      kill -9 $pid &> /dev/null
   done
   echo "${LANG_CRON_OFF}"
else
   echo "${LANG_CRON_ERROR}:$regular_update"
   echo "${LANG_CRON_ERROR2}"
fi