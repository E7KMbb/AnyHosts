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

### • 填写方式为每行一条

## 本地hosts

* 在 `/sdcard/Android/AnyHosts/local_hosts` 内填写位于本地hosts文件的目录。

### • 填写方式为每行一条

## 黑名单

* 在`/sdcard/Android/AnyHosts/black_list`内填写自己的规则

* 填写规则

* 仅填写`IP`将屏蔽所有此`IP`词条 即：填写`127.0.0.1`将屏蔽所有此`IP`的规则

* 仅填写`域名`将屏蔽所有和此`域名`相关的词条 即：填写`baidu`将屏蔽所有包含此字段的规则

* 填写`IP+域名`请使用`=`代替空格 即：屏蔽`127.0.0.1 www.baidu.com`请填写`127.0.0.1=www.baidu.com`

### • 填写方式为每行一条

## 用户规则

* 在`/sdcard/Android/AnyHosts/user_rules`内填写自己的规则

* 请使用`=`代替空格

### • 填写方式为每行一条

## 选择配置

* 安装时选择的参数

* 在`/sdcard/Android/AnyHosts/select.ini`中修改参数控制开机自启更新和开机启用定时更新

## 定时更新(默认关闭)

* 控制开启与关闭，将`Cron.ini`中的`regular_update`参数修改为`on/off`，然后执行`Regular_update.sh`便可切换工作状态

* 修改`/sdcard/Android/AnyHosts/Cron.ini`中的参数后执行`Regular_update.sh`以应用，更新时间的填写规则请参考[crontabs命令教程](https://m.runoob.com/linux/linux-comm-crontab.html)

## 卸载

* 通过Magisk Manager卸载模块。

## 应用顺序

* 文件应用顺序如下
```
订阅hosts&本地hosts--->黑名单--->用户规则
```
* 可能遇到的问题:

1.如果你在黑名单中填写`127.0.0.1=www.baidu.com`然后在用户规则中也填入此条那么最终的hosts文件中会存在`127.0.0.1 www.baidu.com`

2.如果你在用户规则中填写规则的`域名`在`订阅hosts&本地hosts`中那么最终的hosts文件中`订阅hosts&本地hosts`中的相关规则将会删除并使用用户规则中的规则

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

## Liense
[GPL-3.0](https://github.com/E7KMbb/AnyHosts/LICENSE)