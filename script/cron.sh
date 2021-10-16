work_dir=/sdcard/Android/Anyhosts
script_dir=${0%/*}

# Local lang
locale=$(getprop persist.sys.locale|awk -F "-" '{print $1"_"$NF}')
[[ ${locale} == "" ]] && locale=$(settings get system system_locales|awk -F "," '{print $1}'|awk -F "-" '{print $1"_"$NF}')
if [ -e $script_dir/${locale}.ini ];then
   . $script_dir/${locale}.ini
else
   . $script_dir/en_US.ini
fi

. $work_dir/Cron.ini

[ -f /data/adb/magisk/busybox ] && alias crond="/data/adb/magisk/busybox crond"

if [ $regular_update = "on" ]; then
   pid_text=$(ps -elf | grep "$script_dir/crontabs" | awk -F ' ' '{print $2}')
   for pid in ${pid_text[*]}; do
      kill -9 $pid &> /dev/null
   done
   if [[ $time_format = "24" || $time_format = "AM" ]]; then
      H="$(echo $time | awk -F ':' '{print $1}')"
      M="$(echo $time | awk -F ':' '{print $2}')"
      if [ $H = "24" ]; then
         export H="0"
      fi
      if [ $M = "00" ]; then
         export M="0"
      elif [ $M = "60" ]; then
           H=$(($H + 1))
           export M="0"
      elif $(echo "$M" | grep -q '^0'); then
         export M="$(echo $time | awk -F ':' '{print $2}' | awk -F '0' '{print $2}')"
      fi
      if [[ $H -gt "23" || $M -gt "59" ]]; then
         echo "${LANG_CRON_ERROR_TIME}"
         exit 1
      fi
   elif [ $time_format = "PM" ]; then
      H="$(($(echo $time | awk -F ':' '{print $1}') + 12))"
      M="$(echo $time | awk -F ':' '{print $2}')"
      if $(echo "$H" | grep -q '^0'); then
         export H="$(echo $time | awk -F ':' '{print $1}' | awk -F '0' '{print $2}')"
      fi
      if [ $M = "00" ]; then
         export M="0"
      elif [ $M = "60" ]; then
         H=$(($H + 1))
         export M="0"
      elif $(echo "$M" | grep -q '^0'); then
         export M="$(echo $time | awk -F ':' '{print $2}' | awk -F '0' '{print $2}')"
      fi
      if [[ $H -gt "23" || $M -gt "59" ]]; then
         echo "${LANG_CRON_ERROR_TIME}"
         exit 1
      fi
   fi
   if [ $wupdate = "y" ]; then
      if [ $mupdate = "y" ]; then
         echo "${LANG_CRON_ERROR_WAM}"
         exit 1
      fi
      DOW="$wday"
   elif [ $wupdate = "n" ]; then
      DOW="*"
   else
      echo "${LANG_CRON_ERROR}:$wupdate"
      echo "${LANG_CRON_ERROR3}"
      exit 1
   fi
   if [ $mupdate = "y" ]; then
      DOM="$wdate"
   elif [ $mupdate = "n" ]; then
      DOM="*"
   else
      echo "${LANG_CRON_ERROR}:$mupdate"
      echo "${LANG_CRON_ERROR3}"
      exit 1
   fi
   rm -rf $script_dir/crontabs/root
   touch $script_dir/crontabs/root
   echo "$M $H $DOM * $DOW  /system/bin/sh $script_dir/functions.sh" >> $script_dir/crontabs/root
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