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

### • Fill in rules is one rule per line.

## local_hosts

* Fill in the directory of the local hosts file in `/sdcard/Android/AnyHosts/local_hosts`

### • Fill in rules is one rule per line.

## black_list

* Fill your own rules in `/sdcard/Android/AnyHosts/black_list`

* Fill in rules.

* Fill in the `IP` will block all this `IP`. (Fill in `127.0.0.1` to block all this `IP`)

* Fill in the `DomainName` block all and this `DomainName` related entry. (Fill in the `google` to block all rules that contain this field)

* Fill in the `IP`+`DomainName` please use `=` instead of space. (Block `127.0.0.1 www.google.com` please fill in the `127.0.0.1=www.google.com` )

### • Fill in rules is one rule per line.

## user_rules

* Fill your own rules in `/sdcard/Android/AnyHosts/user_rules`

* Please use `=` instead of spaces

### • Fill in rules is one rule per line.

## select.ini

* Parameters selected during installation

* Modify the parameters in `/sdcard/Android/AnyHosts/select.ini` to control the boot-up update and start-up timing update

### Timed update (default disallow)

* To control the opening and closing, modify the parameter of `regular_update` in `Cron.ini` to `on/off`, and then execute `Regular_update.sh` to switch the working state

* Modify the parameters in `/sdcard/Android/AnyHosts/Cron.ini` and execute `Regular_update.sh` to apply. Please refer to [crontabs command tutorial](https://opensource.com/article/17/11/how-use-cron-linux) for the rules for filling in the update time

## Uninstall

* Uninstall the module via Magisk Manager App.

## Execution order

* The order of file executio is as follows
```
subscription hosts & local_hosts ---> black_list ---> user_rules
```
* Possible problems:

1.If you fill in the black_list `127.0.0.1=www.google.com` and then fill in this entry in the user_rules, then there will be `127.0.0.1 www.google.com` in the final hosts file

2.If you fill in the `DomainName` of the rule in the user_rules in the `subscription hosts & local_hosts`, then the relevant rules in the `subscription hosts & local_hosts` in the final hosts file will be deleted and the rules in the user_rules will be used

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

## Liense
[GPL-3.0](https://github.com/E7KMbb/AnyHosts/LICENSE)
