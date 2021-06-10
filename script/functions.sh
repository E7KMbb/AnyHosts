#!/system/bin/sh
hosts_dir=/data/adb/modules/hosts/system/etc
work_dir=/sdcard/Android/AnyHosts
script_dir=${0%/*}
curdate="`date +%Y-%m-%d,%H:%M:%S`"

# Local lang
locale=$(getprop persist.sys.locale|awk -F "-" '{print $1"_"$NF}')
[[ ${locale} == "" ]] && locale=$(settings get system system_locales|awk -F "," '{print $1}'|awk -F "-" '{print $1"_"$NF}')
if [ -e $script_dir/${locale}.ini ];then
   sh $script_dir/${locale}.ini
else
   sh $script_dir/en_US.ini
fi

# Create work files
if [ ! -d $work_dir ];then
   mkdir -p $work_dir
fi
if [ ! -e $work_dir/Cron.ini ];then
   touch $work_dir/Cron.ini
   LANG_CRON
fi
if [ ! -e $work_dir/select.ini ];then
   touch $work_dir/select.ini
   echo "# ${LANG_BOOT_START_UPDATE_SELECT}. true/false" >> $work_dir/select.ini
   echo "update_boot_start='false'" >> $work_dir/select.ini
   echo "# ${LANG_BOOT_START_REGULAR_UPDATE_SELECT}. true/false" >> $work_dir/select.ini
   echo "regular_update_boot_start='false'" >> $work_dir/select.ini
fi
if [ ! -e $work_dir/update.log ];then
   touch $work_dir/update.log
   echo "paceholder" >> $work_dir/update.log
   sed -i "G;G;G;G;G" $work_dir/update.log
   sed -i '1d' $work_dir/update.log
fi
if [ ! -e $work_dir/Regular_update.sh ];then
   touch $work_dir/Regular_update.sh
   echo "${LANG_REGULAR_UPDATE}" >> $work_dir/Regular_update.sh
   echo "sh $script_dir/cron.sh" >> $work_dir/Regular_update.sh
fi
if [ ! -e $work_dir/Start.sh ];then
   touch $work_dir/Start.sh
   echo "${LANG_START}" >> $work_dir/Start.sh
   echo "sh $script_dir/functions.sh" >> $work_dir/Start.sh
fi
if [ ! -e $work_dir/hosts_link ];then
   touch $work_dir/hosts_link
fi
if [ ! -e $work_dir/user_rules ];then
   touch $work_dir/user_rules
fi
if [ ! -e $work_dir/black_list ];then
   touch $work_dir/black_list
fi

# Check network connection
for i in $(seq 1 100); do
   if [[ $(ping -c 1 1.2.4.8) ]] >/dev/null 2>&1; then
   break;
   elif [[ $(ping -c 1 8.8.8.8) ]] >/dev/null 2>&1; then
   break;
   elif [[ $(ping -c 1 114.114.114.114) ]] >/dev/null 2>&1; then
   break;
   fi
   if [ $i = 100 ]; then
      echo "${LANG_NETWORK_ERROR}"
	  echo "${LANG_NETWORK_ERROR}" >> $work_dir/update.log
	  exit 0
   fi
   sleep 10
done

# Download hosts
cycles=0
hosts_link_text=$(cat $work_dir/hosts_link)
if $(curl -V > /dev/null 2>&1) ; then
    for hosts_link in ${hosts_link_text[*]}; do
       cycles=$((${cycles} + 1))
       curl "${hosts_link}" -k -L -o "$work_dir/$cycles" >&2
       if [ ! -e $work_dir/$cycles ]; then
          rm -rf $work_dir/$cycles
          touch $work_dir/$cycles
          echo "${LANG_DOWNLOAD2_ERROR}"
          echo "${LANG_DOWNLOAD2_ERROR}" >> $work_dir/update.log
       fi
    done
elif $(wget --help > /dev/null 2>&1) ; then
    for hosts_link in ${hosts_link_text[*]}; do
       cycles=$((${cycles} + 1))
       wget --no-check-certificate ${hosts_link} -O $work_dir/$cycles
       if [ ! -e $work_dir/$cycles ]; then
          rm -rf $work_dir/$cycles
          touch $work_dir/$cycles
          echo "${LANG_DOWNLOAD2_ERROR}"
          echo "${LANG_DOWNLOAD2_ERROR}" >> $work_dir/update.log
       fi
    done
else
    echo "${LANG_DOWNLOAD_ERROR}"
    echo "${LANG_DOWNLOAD_ERROR}" >> $work_dir/update.log
    exit 0
fi

# Merge hosts
for name in $(seq 1 $((${cycles} - 1))); do
   cat $work_dir/$name $work_dir/$(($name + 1)) > $work_dir/paceholder
   rm -rf $work_dir/$name
   rm -rf $work_dir/$(($name + 1))
   mv $work_dir/paceholder $work_dir/$(($name + 1))
done

# User rules
if [ -s $work_dir/user_rules ];then
   cat $work_dir/$(($name + 1)) $work_dir/user_rules > $work_dir/paceholder
   rm -rf $work_dir/$(($name + 1))
   mv $work_dir/paceholder $work_dir/$(($name + 1))
fi

# GitHub access acceleration hosts
GitHub_IP=$(curl --user-agent "Mozilla/5.0 (Linux; Android 7.1.1; Mi Note 3 Build/NMF26X; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/61.0.3163.98 Mobile Safari/537.36" -skL "https://github.com.ipaddress.com/" | egrep -o '<li>[0-9.]{11,}</li>' | egrep -o -m 1 '[0-9.]{11,}')
GitHub_IP2=$(curl --user-agent "Mozilla/5.0 (Linux; Android 7.1.1; Mi Note 3 Build/NMF26X; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/61.0.3163.98 Mobile Safari/537.36" -skL "https://fastly.net.ipaddress.com/github.global.ssl.fastly.net" | egrep -o '<li>[0-9.]{11,}</li>' | egrep -o -m 1 '[0-9.]{11,}')
GitHub_IP3=$(curl --user-agent "Mozilla/5.0 (Linux; Android 7.1.1; Mi Note 3 Build/NMF26X; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/61.0.3163.98 Mobile Safari/537.36" -skL "https://github.com.ipaddress.com/assets-cdn.github.com" | egrep -o '<li>[0-9.]{11,}</li>' | egrep -o -m 1 '[0-9.]{11,}')
if [[ ! -z "${GitHub_IP}" || ! -z "${GitHub_IP2}" || ! -z "${GitHub_IP3}" ]]; then
   if ( ! grep " github.com" $work_dir/$(($name + 1))); then
      echo "${GitHub_IP} github.com" >> $work_dir/$(($name + 1))
   fi
   if ( ! grep " github.global.ssl.fastly.net" $work_dir/$(($name + 1))); then
      echo "${GitHub_IP2} github.global.ssl.fastly.net" >> $work_dir/$(($name + 1))
   fi
   if ( ! grep " assets-cdn.github.com" $work_dir/$(($name + 1))); then
      echo "${GitHub_IP3} assets-cdn.github.com" >> $work_dir/$(($name + 1))
   fi
fi

# Remove duplicates
sed -i '/^ /d' $work_dir/$(($name + 1))
sed -i '/^#/d' $work_dir/$(($name + 1))
sed -i '/^</d' $work_dir/$(($name + 1))
sed -i '/^>/d' $work_dir/$(($name + 1))
sed -i '/^|/d' $work_dir/$(($name + 1))
sed -i '/^@/d' $work_dir/$(($name + 1))
sed -i '/^./d' $work_dir/$(($name + 1))
sed -i '/^-/d' $work_dir/$(($name + 1))
sed -i '/^!/d' $work_dir/$(($name + 1))
sed -i '/^$/d' $work_dir/$(($name + 1))
sed -i '/^\[/d' $work_dir/$(($name + 1))
sed -i '/^~/d' $work_dir/$(($name + 1))
sed -i '/localhost/d' $work_dir/$(($name + 1))
sed -i '/ip6-localhost/d' $work_dir/$(($name + 1))
sed -i '/ip6-loopback/d' $work_dir/$(($name + 1))
sed -i "s/0.0.0.0 /127.0.0.1 /g" $work_dir/$(($name + 1))
cat $work_dir/$(($name + 1)) |sort|uniq > $work_dir/hosts
rm -rf $work_dir/$(($name + 1))

# Black list
if [ -s $work_dir/black_list ];then
   black_list_text=$(cat $work_dir/black_list)
   for black_list in ${black_list_text[*]}; do
     if echo ${black_list} | grep -q "="; then
       print1=$(echo "$black_list" | awk -F '=' '{print $1}')
       print2=$(echo "$black_list" | awk -F '=' '{print $2}')
       sed -i '/'$print1'[ ]'$print2'/d' $work_dir/hosts
     else
       sed -i '/'$black_list'/d' $work_dir/hosts
     fi
   done
fi

# Add necessary content
sed -i '1 i #********************************************************************************' $work_dir/hosts
sed -i '2 i #By AnyHosts for AiSauce' $work_dir/hosts
sed -i '3 i #********************************************************************************' $work_dir/hosts
sed -i '3G' $work_dir/hosts
sed -i '5 i 127.0.0.1 localhost' $work_dir/hosts
sed -i '6 i 127.0.0.1 ip6-localhost' $work_dir/hosts
sed -i '7 i 127.0.0.1 ip6-loopback' $work_dir/hosts
sed -i '8 i ::1 localhost' $work_dir/hosts
sed -i '9 i ::1 ip6-localhost' $work_dir/hosts
sed -i '10 i ::1 ip6-loopback' $work_dir/hosts

# Check for updates
Now=$(md5sum $hosts_dir/hosts | awk '{print $1}')
New=$(md5sum  $work_dir/hosts | awk '{print $1}')
if [ $Now = $New ]; then
   rm -rf $work_dir/hosts
   echo "${LANG_NOT_UPDATE}"
   echo "${LANG_NOT_UPDATE}: $curdate" >> $work_dir/update.log
else
   rm -rf $hosts_dir/hosts
   mv -f $work_dir/hosts $hosts_dir/hosts
   chmod 644 $hosts_dir/hosts
   chown 0:0 $hosts_dir/hosts
   chcon u:object_r:system_file:s0 $hosts_dir/hosts
   echo "${LANG_LAST_UPDATE_TIME}: $curdate ${LANG_HOSTS_DIR}:$hosts_dir/hosts" >> $work_dir/update.log
   sed -i '1d' $work_dir/update.log
fi
