#!/bin/bash
MYSQL_PASSWORD="mypassword"

echo "mysql root and admin password: $MYSQL_PASSWORD"

echo "$MYSQL_PASSWORD" > /mysql-root-pw.txt

/sbin/service mysqld status || /sbin/service mysqld start
sleep 2

mysqladmin -uroot password $MYSQL_PASSWORD 

mysql -uroot -p"$MYSQL_PASSWORD" -e "INSERT INTO mysql.user (Host,User,Password) VALUES('%','admin',PASSWORD('${MYSQL_PASSWORD}'));"

mysql -uroot -p"$MYSQL_PASSWORD" -e "GRANT ALL ON *.* TO 'admin'@'%';"

mysqladmin -uroot -p"$MYSQL_PASSWORD" create zabbix

mysql -uroot -p"$MYSQL_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8;"

mysql -uroot -D zabbix -p"$MYSQL_PASSWORD" < "/tmp/mysql_schema.sql"
mysql -uroot -D zabbix -p"$MYSQL_PASSWORD" < "/tmp/mysql_images.sql"
mysql -uroot -D zabbix -p"$MYSQL_PASSWORD" < "/tmp/mysql_data.sql"

mysql -uroot -p"$MYSQL_PASSWORD" -e "INSERT INTO mysql.user (Host,User,Password) VALUES('localhost','zabbix',PASSWORD('zabbix'));"

mysql -uroot -p"$MYSQL_PASSWORD" -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP ON zabbix.* TO 'zabbix'@'%';"
