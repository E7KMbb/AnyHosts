# AnyHosts

这是一个用于在开机后自动更新自定义订阅hosts的Magisk模块

## 安装

您可以下载release里发布的文件，通过Magisk Manager进行安装。

## 使用

* 安装后请先填写订阅地址

* 在Magisk Manager设置中打开 `Systemless Hosts`。

* 您的订阅将在每次重启后更新。

## 订阅链接

* 在 `/sdcard/Android/AnyHosts/hosts_link` 内填写订阅地址。

### • 填写方式为写在同一行每个链接间隔一个空格或每行一个

## 用户规则

* 在`/sdcard/Android/AnyHosts/user_rules`内填写自己的规则

### • 规则填写格式为hosts填写规则 即：每行一个

## 黑名单

* 在`/sdcard/Android/AnyHosts/black_list`内填写自己的规则

* 填写规则

* 仅填写`IP`将屏蔽所有此`IP`词条 即：填写`127.0.0.1`将屏蔽所有此`IP`的规则

* 仅填写`域名`将屏蔽所有和此`域名`相关的词条 即：填写`baidu`将屏蔽所有包含此字段的规则

* 填写`IP+域名`请使用`=`代替空格 即：屏蔽`127.0.0.1 www.baidu.com`请填写`127.0.0.1=www.baidu.com`

### • 填写方式为写在同一行每个规则间隔一个空格或每行一个

## 卸载

* 通过Magisk Manager卸载模块。

## 翻译

* 使用su权限执行以下命令 
```
locale=$(getprop persist.sys.locale|awk -F "-" '{print $1"_"$NF}')
[[ ${locale} == "" ]] && locale=$(settings get system system_locales|awk -F "," '{print $1}'|awk -F "-" '{print $1"_"$NF}')
echo "${locale}"
```
* 创建带有`.ini`后缀的输出名称文件，翻译相关变量并提交pr

## 链接
* [GitHub](https://github.com/E7KMbb/AnyHosts)

* [TG Group](https://t.me/aisauceupdate)

* [捐赠](https://docs.qq.com/doc/DWVJKWVVDWURQZUZK?disableReturnList=1&_from=1)
