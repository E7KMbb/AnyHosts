##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into post-fs-data.sh or service.sh
# 5. Add your additional or modified system properties into system.prop
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
##########################################################################################

##########################################################################################
# Variables
##########################################################################################

# If you need even more customization and prefer to do everything on your own, declare SKIPUNZIP=1 in customize.sh to skip the extraction and applying default permissions/secontext steps.
# Be aware that by doing so, your customize.sh will then be responsible to install everything by itself.
SKIPUNZIP=1
# If you need to call busybox inside MAGISK
# Please mark ASH_STANDALONE=1 in customize.sh
ASH_STANDALONE=1


##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"
##########################################################################################
# Install
##########################################################################################

# Extract $ZIPFILE to $MODPATH
ui_print "- Extracting module files"
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2

# Local lang
locale=$(getprop persist.sys.locale|awk -F "-" '{print $1"_"$NF}')
[[ ${locale} == "" ]] && locale=$(settings get system system_locales|awk -F "," '{print $1}'|awk -F "-" '{print $1"_"$NF}')
if [ -e $MODPATH/script/${locale}.ini ];then
   . $MODPATH/script/${locale}.ini
else
   ui_print " Without your language file, the default language en_US will be used."
   ui_print " If you need, you can go to the GitHub repository of this module for translation"
   . $MODPATH/script/en_US.ini
fi

ui_print "${LANG_WARNING}"

sed -i 's/<DESCRIPTION>/'"${LANG_DESCRIPTION}"'/g' $MODPATH/module.prop

# External Tools
chmod -R 0755 $MODPATH/tools
 
chooseport_legacy() {
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  # Calling it first time detects previous input. Calling it second time will do what we want
  [ "$1" ] && local delay=$1 || local delay=3
  local error=false
  while true; do
    timeout 0 $MODPATH/tools/$ARCH32/keycheck
    timeout $delay $MODPATH/tools/$ARCH32/keycheck
    local sel=$?
    if [ $sel -eq 42 ]; then
      return 0
    elif [ $sel -eq 41 ]; then
      return 1
    elif $error; then
      abort "${LANG_VOLUME_KEY_NOT_DETECTED}!"
    else
      error=true
      echo "${LANG_VOLUME_KEY_NOT_DETECTED}. ${LANG_VOLUME_KEY_TRY_AGAIN}"
    fi
  done
}
 
chooseport() {
  # Original idea by chainfire and ianmacd @xda-developers
  [ "$1" ] && local delay=$1 || local delay=3
  local error=false 
  while true; do
    local count=0
    while true; do
      timeout $delay /system/bin/getevent -lqc 1 2>&1 > $TMPDIR/events &
      sleep 0.5; count=$((count + 1))
      if (`grep -q 'KEY_VOLUMEUP *DOWN' $TMPDIR/events`); then
        return 0
      elif (`grep -q 'KEY_VOLUMEDOWN *DOWN' $TMPDIR/events`); then
        return 1
      fi
      [ $count -gt 10 ] && break
    done
    if $error; then
      # abort "${LANG_VOLUME_KEY_NOT_DETECTED}!"
      echo "${LANG_VOLUME_KEY_NOT_DETECTED}. ${LANG_VOLUME_KEY_TRYING_KEYCHECK}"
      export chooseport=chooseport_legacy VKSEL=chooseport_legacy
      chooseport_legacy $delay
      return $?
    else
      error=true
      echo "${LANG_VOLUME_KEY_NOT_DETECTED}. ${LANG_VOLUME_KEY_TRY_AGAIN}"
    fi
  done
}

# Create work files
work_dir=/sdcard/Android/AnyHosts
if [ ! -d $work_dir ];then
   mkdir -p $work_dir
fi
if (grep "* * * * *" $work_dir/Cron.ini); then
   rm -rf $work_dir/Cron.ini
fi
if [ ! -e $work_dir/Cron.ini ];then
   touch $work_dir/Cron.ini
   ${LANG_CRON}
fi
rm -rf $work_dir/select.ini
if [ ! -e $work_dir/select.ini ];then
   touch $work_dir/select.ini
   echo "# ${LANG_BOOT_START_UPDATE_SELECT}. true/false" >> $work_dir/select.ini
   echo "update_boot_start='<update_boot>'" >> $work_dir/select.ini
   echo "# ${LANG_BOOT_START_REGULAR_UPDATE_SELECT}. true/false" >> $work_dir/select.ini
   echo "regular_update_boot_start='<regular_update_boot>'" >> $work_dir/select.ini
fi
if [ ! -e $work_dir/update.log ];then
   touch $work_dir/update.log
   echo "paceholder" >> $work_dir/update.log
   sed -i "G;G;G;G;G" $work_dir/update.log
   sed -i '1d' $work_dir/update.log
fi
rm -rf $work_dir/Regular_update.sh
if [ ! -e $work_dir/Regular_update.sh ];then
   touch $work_dir/Regular_update.sh
   echo "${LANG_REGULAR_UPDATE}" >> $work_dir/Regular_update.sh
   echo "sh $NVBASE/modules/$MODID/script/cron.sh" >> $work_dir/Regular_update.sh
fi
rm -rf $work_dir/Start.sh
if [ ! -e $work_dir/Start.sh ];then
   touch $work_dir/Start.sh
   echo "${LANG_START}" >> $work_dir/Start.sh
   echo "sh $NVBASE/modules/$MODID/script/functions.sh" >> $work_dir/Start.sh
fi
if [ ! -e $work_dir/hosts_link ];then
   touch $work_dir/hosts_link
fi
if [ ! -e $work_dir/local_hosts ]; then
   touch $work_dir/local_hosts
fi
if [ ! -e $work_dir/user_rules ];then
   touch $work_dir/user_rules
fi
if [ ! -e $work_dir/black_list ];then
   touch $work_dir/black_list
fi

ui_print "${LANG_BOOT_START_UPDATE_SELECT}"
ui_print "${LANG_SELECT_YES}"
ui_print "${LANG_SELECT_NO}"
if chooseport; then
  ui_print "${LANG_SELECTED_YES}"
  sed -i "s/<update_boot>/true/g" $work_dir/select.ini
else
  ui_print "${LANG_SELECTED_NO}"
  sed -i "s/<update_boot>/false/g" $work_dir/select.ini
fi

ui_print "${LANG_BOOT_START_REGULAR_UPDATE_SELECT}"
ui_print "${LANG_SELECT_YES}"
ui_print "${LANG_SELECT_NO}"
if chooseport; then
  ui_print "${LANG_SELECTED_YES}"
  sed -i "s/<regular_update_boot>/true/g" $work_dir/select.ini
else
  ui_print "${LANG_SELECTED_NO}"
  sed -i "s/<regular_update_boot>/false/g" $work_dir/select.ini
fi

# Delete extra files
rm -rf \
$MODPATH/system/placeholder $MODPATH/customize.sh \
$MODPATH/*.md $MODPATH/.git* $MODPATH/LICENSE $MODPATH/tools 4>/dev/null

##########################################################################################
# Permissions
##########################################################################################

# Note that all files/folders in magisk module directory have the $MODPATH prefix - keep this prefix on all of your files/folders
# Some examples:
  
# For directories (includes files in them):
# set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)

# set_perm_recursive $MODPATH/system/lib 0 0 0755 0644
# set_perm_recursive $MODPATH/system/vendor/lib/soundfx 0 0 0755 0644

# For files (not in directories taken care of above)
# set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  
# set_perm $MODPATH/system/lib/libart.so 0 0 0644
# set_perm /data/local/tmp/file.txt 0 0 644
  
# The following is the default rule, DO NOT remove
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $MODPATH/script 0 0 0777 0777
