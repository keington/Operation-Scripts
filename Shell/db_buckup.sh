#!/bin/bash

#备份路径
BACKUP=/data/backup/db

#显示当前时间
DATATIME=$(date "+%Y-%m-%d_%H%M%S")

#数据库地址
HOST=localhost

#数据库用户名
DB_USER=root

#数据库密码
DB_PW=123qwe..

#备份的数据库名
DATABASE=db_shell

#开始备份数据库提示语
echo "开始备份数据库${DATABASE}"

#创建备份目录，如果不存在，则新建目录
[ ! -d ${BACKUP}/${DATATIME} ] && mkdir -p "${BACKUP}/${DATATIME}"

#备份数据库
mysqldump -u${DB_USER} -p${DB_PW} --host=${HOST}  --databases ${DATABASE} | gzip > ${BACKUP}/${DATATIME}/$DATATIME.sql.gz

#将文件处理成  tar.gz 
cd ${BACKUP}
tar -zcvf $DATATIME.tar.gz ${DATATIME}

#删除已备份的目录
rm -rf  ${BACKUP}/${DATATIME}

#删除10天前的备份文件
find ${BACKUP} -atime +10 -name "*.tar.gz" -exec rm -rf {} \;

#结束备份数据库提示语
echo "数据库${DATABASE}备份成功!"
