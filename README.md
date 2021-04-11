# AnyHosts

[简体中文](<https://github.com/E7KMbb/AnyHosts/blob/master/README_zh.md>)

This is a Magisk module used to boot update custom subscription hosts after booting.

## Install

You can download the release installer zip file and install it via the Magisk Manager App.

## Usage

* Please fill in the subscription address after installation.

* Open `Systemless Hosts` in Magisk Manager settings.

* Your subscription will be updated after every reboot.

## hosts_link

* Fill in your subscription address in `/sdcard/Android/AnyHosts/hosts_link`

### • Fill in rules is each link should separate by space or just one link per line.

## user_rules

* Fill your own rules in `/sdcard/Android/AnyHosts/user_rules`

### • Fill in rules is one rule per line.

## black_list

* Fill your own rules in `/sdcard/Android/AnyHosts/black_list`

* Fill in rules.

* Fill in the `IP` will block all this `IP`. (Fill in `127.0.0.1` to block all this `IP`)

* Fill in the `DomainName` block all and this `DomainName` related entry. (Fill in the `google` to block all rules that contain this field)

* Fill in the `IP`+`DomainName` please use `=` instead of space. (Block `127.0.0.1 www.google.com` please fill in the `127.0.0.1=www.google.com` )

### • Fill in rules is each rule should separate by space or just one rule per line.

## Uninstall

* Uninstall the module via Magisk Manager App.

## Translation

* Sh the following commands with su permissions 
```
locale=$(getprop persist.sys.locale|awk -F "-" '{print $1"_"$NF}')
[[ ${locale} == "" ]] && locale=$(settings get system system_locales|awk -F "," '{print $1}'|awk -F "-" '{print $1"_"$NF}')
echo "${locale}"
```
* Create an output name file with `.ini` suffix, translate related variables and submit pr

## Links
* [GitHub](https://github.com/E7KMbb/AnyHosts)

* [TG Group](https://t.me/aisauceupdate)