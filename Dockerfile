FROM centos:centos6
MAINTAINER Stephen Price <steeef@gmail.com>

RUN rpm --import https://fedoraproject.org/static/0608B895.txt \
    && rpm -ivh https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN rpm --import http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX \
    && rpm -ivh http://repo.zabbix.com/zabbix/2.4/rhel/6/x86_64/zabbix-release-2.4-1.el6.noarch.rpm

RUN yum makecache && yum -y install \
    httpd \
    java-1.7.0-openjdk \
    monit \
    mysql \
    mysql-server \
    net-snmp \
    net-snmp-devel \
    net-snmp-libs \
    net-snmp-perl \
    net-snmp-python \
    net-snmp-utils \
    php \
    php-ldap \
    php-mysql \
    php-snmp \
    zabbix-agent \
    zabbix-get \
    zabbix-java-gateway \
    zabbix-sender \
    zabbix-server \
    zabbix-server-mysql \
    zabbix-web \
    zabbix-web-mysql \
    && yum clean all

# MySQL
ADD ./mysql/my.cnf /etc/mysql/conf.d/my.cnf
ADD ./mysql/create/data.sql /tmp/mysql_data.sql
ADD ./mysql/create/images.sql /tmp/mysql_images.sql
ADD ./mysql/create/schema.sql /tmp/mysql_schema.sql
# Zabbix Conf Files
ADD ./zabbix/zabbix.ini 				/etc/php.d/zabbix.ini
ADD ./zabbix/httpd_zabbix.conf  		/etc/httpd/conf.d/zabbix.conf
ADD ./zabbix/zabbix.conf.php    		/etc/zabbix/web/zabbix.conf.php
ADD ./zabbix/zabbix_agentd.conf 		/etc/zabbix/zabbix_agentd.conf
ADD ./zabbix/zabbix_java_gateway.conf 	/etc/zabbix/zabbix_java_gateway.conf
ADD ./zabbix/zabbix_server.conf 		/etc/zabbix/zabbix_server.conf

RUN chmod 640 /etc/zabbix/zabbix_server.conf \
    && chown root:zabbix /etc/zabbix/zabbix_server.conf

# Monit
ADD ./monitrc /etc/monitrc
RUN chmod 600 /etc/monitrc

# Add the script that will start the repo.
ADD ./scripts/start.sh /start.sh

# Expose the Ports used by
# * Zabbix services
# * Apache with Zabbix UI
# * Monit
EXPOSE 10051 10052 80 2812

VOLUME ["/var/lib/mysql", "/usr/lib/zabbix/alertscripts", "/usr/lib/zabbix/externalscripts", "/etc/zabbix/zabbix_agentd.d"]
CMD ["/start.sh"]
