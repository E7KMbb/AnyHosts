#!/system/bin/sh
hosts_dir=/data/adb/modules/hosts/system/etc
work_dir=/sdcard/Android/AnyHosts
script_dir=${0%/*}
curdate="`date +%Y-%m-%d,%H:%M:%S`"

# Local lang
locale=$(getprop persist.sys.locale|awk -F "-" '{print $1"_"$NF}')
[[ ${locale} == "" ]] && locale=$(settings get system system_locales|awk -F "," '{print $1}'|awk -F "-" '{print $1"_"$NF}')
if [ -e $script_dir/${locale}.ini ]; then
   . $script_dir/${locale}.ini
else
   . $script_dir/en_US.ini
fi

# Create work files
if [ ! -d $work_dir ]; then
   mkdir -p $work_dir
fi
if [ ! -e $work_dir/Cron.ini ]; then
   touch $work_dir/Cron.ini
   ${LANG_CRON}
fi
if [ ! -e $work_dir/select.ini ]; then
   touch $work_dir/select.ini
   echo "# ${LANG_BOOT_START_UPDATE_SELECT}. true/false" >> $work_dir/select.ini
   echo "update_boot_start='false'" >> $work_dir/select.ini
   echo "# ${LANG_BOOT_START_REGULAR_UPDATE_SELECT}. true/false" >> $work_dir/select.ini
   echo "regular_update_boot_start='false'" >> $work_dir/select.ini
fi
if [ ! -e $work_dir/update.log ]; then
   touch $work_dir/update.log
   echo "paceholder" >> $work_dir/update.log
   sed -i "G;G;G;G;G" $work_dir/update.log
   sed -i '1d' $work_dir/update.log
fi
if [ ! -e $work_dir/Regular_update.sh ]; then
   touch $work_dir/Regular_update.sh
   echo "${LANG_REGULAR_UPDATE}" >> $work_dir/Regular_update.sh
   echo "sh $script_dir/cron.sh" >> $work_dir/Regular_update.sh
fi
if [ ! -e $work_dir/Start.sh ]; then
   touch $work_dir/Start.sh
   echo "${LANG_START}" >> $work_dir/Start.sh
   echo "sh $script_dir/functions.sh" >> $work_dir/Start.sh
fi
if [ ! -e $work_dir/hosts_link ]; then
   touch $work_dir/hosts_link
fi
if [ ! -e $work_dir/local_hosts ]; then
   touch $work_dir/local_hosts
fi
if [ ! -e $work_dir/user_rules ]; then
   touch $work_dir/user_rules
fi
if [ ! -e $work_dir/black_list ]; then
   touch $work_dir/black_list
fi

# Check if the link exists
if [ ! -s $work_dir/hosts_link ]; then
   echo "${LANG_LINK_ERROR}"
   exit 0
fi

# Check network connection
for test_number in $(seq 1 100); do
   if [[ $(ping -c 1 1.2.4.8) ]] >/dev/null 2>&1; then
   break;
   elif [[ $(ping -c 1 8.8.8.8) ]] >/dev/null 2>&1; then
   break;
   elif [[ $(ping -c 1 114.114.114.114) ]] >/dev/null 2>&1; then
   break;
   fi
   if [ $test_number = 100 ]; then
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
    download_command="c"
    for hosts_link in ${hosts_link_text[*]}; do
       echo "${hosts_link}" | grep -q '^#' && continue
       [[ `echo "${hosts_link}" | grep -c "^http"` = '0' ]] && continue
       cycles=$((${cycles} + 1))
       curl "${hosts_link}" -k -L -o "$work_dir/$cycles" >&2
       if [[ $? -gt 0 || ! -e $work_dir/$cycles ]]; then
          rm -rf $work_dir/$cycles
          touch $work_dir/$cycles
          echo "${LANG_DOWNLOAD2_ERROR}"
          echo "${LANG_DOWNLOAD2_ERROR}" >> $work_dir/update.log
       fi
    done
elif $(wget --help > /dev/null 2>&1) ; then
    download_command="w"
    for hosts_link in ${hosts_link_text[*]}; do
       echo "${hosts_link}" | grep -q '^#' && continue
       [[ `echo "${hosts_link}" | grep -c "^http"` = '0' ]] && continue
       cycles=$((${cycles} + 1))
       wget --no-check-certificate ${hosts_link} -O $work_dir/$cycles
       if [[ $? -gt 0 || ! -e $work_dir/$cycles ]]; then
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
if [[ ${cycles} = "0" || ${cycles} = "1" ]]; then
   name=0
   if [ ! -e $work_dir/1 ]; then
      touch $work_dir/1
   fi
elif [ ${cycles} = "2" ]; then
   name=1
   cat $work_dir/$name $work_dir/$(($name+1)) > $work_dir/paceholder
   rm -rf $work_dir/$name
   rm -rf $work_dir/$(($name+1))
   mv $work_dir/paceholder $work_dir/$(($name+1))
else
   for name in $(seq 1 $((${cycles} - 1))); do
      cat $work_dir/$name $work_dir/$(($name+1)) > $work_dir/paceholder
      rm -rf $work_dir/$name
      rm -rf $work_dir/$(($name+1))
      mv $work_dir/paceholder $work_dir/$(($name+1))
   done
fi

# Local hosts
if [ -s $work_dir/local_hosts ];then
   local_hosts_text=$(cat $work_dir/local_hosts)
   for local_hosts_dir in ${local_hosts_text[*]}; do
      echo "${local_hosts_dir}" | grep -q '^#' && continue
      cat ${local_hosts_dir} $work_dir/$(($name+1)) > $work_dir/paceholder
      rm -rf $work_dir/$(($name+1))
      mv $work_dir/paceholder $work_dir/$(($name+1))
   done
fi

# GitHub access acceleration hosts
GitHub_access_acceleration() {
   if ( ! grep " $3" "$work_dir/$(($name+1))") ; then
      if [ "${download_command}" = "c" ]; then
         GitHub_IP="$(curl --user-agent "${ua}" -skL "$2" | egrep -o '<li>[0-9.]{11,}</li>' | egrep -o -m 1 '[0-9.]{11,}')"
      else
         wget -U "${ua}" --no-check-certificate -O $script_dir/$1 $2
         GitHub_IP=$(cat $script_dir/$1 | egrep -o '<li>[0-9.]{11,}</li>' | egrep -o -m 1 '[0-9.]{11,}')
         rm -rf $script_dir/$1
      fi
      if [ ! -z "${GitHub_IP}" ]; then
         echo "${GitHub_IP} $3" >> $work_dir/$(($name+1))
      fi
   fi
}
model="$(getprop ro.product.model)"
version=$(echo $(($(($RANDOM%3))+9)))
ua="Mozilla/5.0 (Linux; Android ${version}; ${model}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.115 Mobile Safari/537.36"
GitHub_access_acceleration "ip1" "https://github.com.ipaddress.com/" "www.github.com"
GitHub_access_acceleration "ip2" "https://fastly.net.ipaddress.com/github.global.ssl.fastly.net" "github.global.ssl.fastly.net"
GitHub_access_acceleration "ip3" "https://github.com.ipaddress.com/assets-cdn.github.com" "assets-cdn.github.com"

# Remove duplicates
sed -i '/^ /d' $work_dir/$(($name+1))
sed -i '/^#/d' $work_dir/$(($name+1))
sed -i '/^</d' $work_dir/$(($name+1))
sed -i '/^>/d' $work_dir/$(($name+1))
sed -i '/^|/d' $work_dir/$(($name+1))
sed -i '/^-/d' $work_dir/$(($name+1))
sed -i '/^\./d' $work_dir/$(($name+1))
sed -i '/^\!/d' $work_dir/$(($name+1))
sed -i '/^\@/d' $work_dir/$(($name+1))
sed -i '/^\$/d' $work_dir/$(($name+1))
sed -i '/^\[/d' $work_dir/$(($name+1))
sed -i '/^\~/d' $work_dir/$(($name+1))
sed -i '/localhost/d' $work_dir/$(($name+1))
sed -i '/ip6-localhost/d' $work_dir/$(($name+1))
sed -i '/ip6-loopback/d' $work_dir/$(($name+1))
sed -i "s/0.0.0.0 /127.0.0.1 /g" $work_dir/$(($name+1))
cat $work_dir/$(($name+1)) |sort|uniq > $work_dir/hosts
rm -rf $work_dir/$(($name+1))

# Black list
if [ -s $work_dir/black_list ];then
   black_list_text=$(cat $work_dir/black_list)
   for black_list in ${black_list_text[*]}; do
     echo "${black_list}" | grep -q '^#' && continue
     if echo ${black_list} | grep -q "="; then
       black_list_print1=$(echo "$black_list" | awk -F '=' '{print $1}')
       black_list_print2=$(echo "$black_list" | awk -F '=' '{print $2}')
       sed -i '/'$black_list_print1'[ ]'$black_list_print2'/d' $work_dir/hosts
     else
       sed -i '/'$black_list'/d' $work_dir/hosts
     fi
   done
fi

# User rules
if [ -s $work_dir/user_rules ];then
   user_rules_text=$(cat $work_dir/user_rules)
   for user_rules in ${user_rules_text[*]}; do
     echo "${user_rules}" | grep -q '^#' && continue
     [[ `echo "${user_rules}" | grep -c "="` = '0' ]] && continue
     user_rules_print1=$(echo "${user_rules}" | awk -F '=' '{print $1}')
     user_rules_print2=$(echo "${user_rules}" | awk -F '=' '{print $2}')
     if [[ ! -z "$(cat $work_dir/hosts | grep "$user_rules_print2")" ]]; then
        sed -i '/ $user_rules_print2/d' $work_dir/hosts
     fi
     echo "$user_rules_print1 $user_rules_print2" >> $work_dir/hosts
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
New=$(md5sum $work_dir/hosts | awk '{print $1}')
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
