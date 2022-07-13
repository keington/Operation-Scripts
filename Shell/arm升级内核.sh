#!/bin/sh
# =================================================
# @Author: 许怀安
# @Version：v1.0
# @Explain: ARM架构Centos7.x操作系统优化脚本
# =================================================

# ===========更改yum源=============================
#备份原有yum源
cp -a /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
#下载新的CentOS-Base.repo文件到/etc/yum.repos.d/目录下
wget -O /etc/yum.repos.d/CentOS-Base.repo https://repo.huaweicloud.com/repository/conf/CentOS-AltArch-7.repo
#清除原有yum源缓存
yum clean all
#生成新的yum源缓存
yum repolist all

# ===========升级内核版本==========================
#查看系统内核版本
uname -r
#查看系统名称及内核版本
uname -a
#查看系统版本
cat /etc/redhat-release
#更新yum源仓库
yum update
#更新内核
yum -y install kernel
#安装依赖组件
yum install openssl098e glibc.i686 libstdc++.i686 -y
yum localinstall
ln -s /usr/lib/libssl.so /usr/lib/libssl.so.6
ln -s /usr/lib/libcrypto.so /usr/lib/libcrypto.so.6
#安装依赖包
yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel nss_ldap openldap openldap-devel  openldap-clients openldap-servers libxslt-devel libevent-devel ntp  libtool-ltdl bison libtool vim-enhanced
#生成系统启动配置引导参数
grub2-mkconfig -o /boot/grub2/grub.cfg
#查看可用内核
cat /boot/grub2/grub.cfg | grep menuentry
#修改开机默认使用内核
grub2-set-default 'CentOS Linux (4.18.1) 7 (AltArch)'
#重启
reboot
#验证
uname -r