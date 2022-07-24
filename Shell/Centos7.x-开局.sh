#!/bin/env bash
# =================================================
# Author: 许怀安
# Version：v1.0
# Explain: Centos7.x操作系统开局
# CPU architecture: x86
# =================================================
# Yum源更换为国内阿里源
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
# add the epel
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
# yum重新建立源缓存
yum clean all
yum makecache
#更新yum源仓库
yum -y update

#启用并导入ELRepo仓库公钥
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
#安装ELRepo仓库的yum源
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
#安装最新版本内核
yum --enablerepo=elrepo-kernel install kernel-ml
#设置默认启动内核的版本，0为
grub2-set-default 0
#生成grub配置文件
grub2-mkconfig -o /boot/grub2/grub.cfg
#删除系统中旧内核(安装yum-utils进行删除)
package-cleanup --oldkernels

# 修改主机名
hostnamectl set-hostname centos-7 

# 安装基础命令
yum -y install expect ntp wget vim lsof net-tools lrzsz dstat psmisc namp curl yum-utils

#添加公网DNS地址
cat >> /etc/resolv.conf << EOF
nameserver 223.5.5.5
nameserver 119.29.29.29
EOF

# 同步时间
yum -y install ntp
/usr/sbin/ntpdate cn.pool.ntp.org
echo "* 4 * * * /usr/sbin/ntpdate cn.pool.ntp.org > /dev/null 2>&1" >> /var/spool/cron/root
systemctl restart crond.service

# 禁用selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

# 开启防火墙
systemctl enable firewalld
# 放行常用端口22、80、443
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent
# 重启firewalld
systemctl restart firewalld

# 优化内核
tee /etc/sysctl.conf <<-'EOF'
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.ip_local_port_range = 4000 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384
EOF
sysctl -p
echo "options nf_conntrack hashsize=819200" >> /etc/modprobe.d/mlx4.conf 
modprobe br_netfilter

#优化ssh远程连接
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%F).bak
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
sed -i 's%#PermitEmptyPasswords no%PermitEmptyPasswords no%' /etc/ssh/sshd_config
systemctl restart sshd.service
sysctl -p