#!/system/bin/sh
work_dir=/sdcard/Android/AnyHosts
script_dir=${0%/*}
hosts_dir=/data/adb/modules/hosts/system/etc
curdate="`date +%Y-%m-%d,%H:%M:%S`"

# Local lang
locale=$(getprop persist.sys.locale|awk -F "-" '{print $1"_"$NF}')
[[ ${locale} == "" ]] && locale=$(settings get system system_locales|awk -F "," '{print $1}'|awk -F "-" '{print $1"_"$NF}')
if [ ! -e $script_dir/${locale}.ini ];then
   source $script_dir/en_US.ini
fi
source $script_dir/${locale}.ini

# Create work files
if [ ! -d $work_dir ];then
   mkdir -p $work_dir
fi
if [ ! -e $work_dir/update.log ];then
   touch $work_dir/update.log
   echo "paceholder" >> $work_dir/update.log
   sed -i "G;G;G;G;G" $work_dir/update.log
   sed -i '1d' $work_dir/update.log
fi
if [ ! -e $work_dir/Start.sh ];then
   touch $work_dir/Start.sh
   echo "${LANG_START}" >> $work_dir/Start.sh
   echo "sh /data/adb/modules/AnyHosts/script/functions.sh" >> $work_dir/Start.sh
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
   ping -c 1 www.baidu.com > /dev/null 2>&1
   if [ $? -eq 0 ];then
   break;
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
       if [ $? -gt 0 ]; then
          rm -rf $work_dir/$cycles
          touch $work_dir/$cycles
          echo "${LANG_DOWNLOAD2_ERROR}"
       fi
    done
elif $(wget --help > /dev/null 2>&1) ; then
    for hosts_link in ${hosts_link_text[*]}; do
       cycles=$((${cycles} + 1))
       wget --no-check-certificate ${hosts_link} -O $work_dir/$cycles
       if [ $? -gt 0 ]; then
          rm -rf $work_dir/$cycles
          touch $work_dir/$cycles
          echo "${LANG_DOWNLOAD2_ERROR}"
       fi
    done
else
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
sed -i '/^#/d' $work_dir/hosts
sed -i '/^</d' $work_dir/hosts
sed -i '/^>/d' $work_dir/hosts
sed -i '/^::1/d' $work_dir/hosts
sed -i '/^|/d' $work_dir/hosts
sed -i '/localhost/d' $work_dir/hosts
sed -i '/ip6-localhost/d' $work_dir/hosts
sed -i '/ip6-loopback/d' $work_dir/hosts
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
   echo "${LANG_NOT_UPDATE}: $curdate" >> $work_dir/update.log
else
   mv -f $work_dir/hosts $hosts_dir/hosts
   chmod 644 $hosts_dir/hosts
   chown 0:0 $hosts_dir/hosts
   chcon u:object_r:system_file:s0 $hosts_dir/hosts
   echo "${LANG_LAST_UPDATE_TIME}: $curdate ${LANG_HOSTS_DIR}:$hosts_dir/hosts" >> $work_dir/update.log
   sed -i '1d' $work_dir/update.log
fi
