#!/bin/bash

if [ ! -f ${NAGIOS_HOME}/etc/htpasswd.users ] ; then
  htpasswd -c -b -s ${NAGIOS_HOME}/etc/htpasswd.users ${NAGIOSADMIN_USER} ${NAGIOSADMIN_PASS}
  chown -R nagios.nagios ${NAGIOS_HOME}/etc/htpasswd.users
fi

if [ ! -z ${INFLUXDB_ENV_ADMIN_USER} ]; then
  INFLUXDB_DB=`echo ${INFLUXDB_ENV_PRE_CREATE_DB:-grafana} | awk -F\; '{print $1}'`
  perl -p -i -e "s/enable_influxdb09 =.*/enable_influxdb09 = True/g" ${GRAPHIOS_CFG} 
  perl -p -i -e "s/#?influxdb_servers =.*/influxdb_servers = influxdb:${INFLUXDB_PORT_8086_TCP_PORT}/g" ${GRAPHIOS_CFG}
  perl -p -i -e "s/#?influxdb_user =.*/influxdb_user = ${INFLUXDB_ENV_ADMIN_USER}/g" ${GRAPHIOS_CFG}
  perl -p -i -e "s/#?influxdb_password =.*/influxdb_password = ${INFLUXDB_ENV_INFLUXDB_INIT_PWD}/g" ${GRAPHIOS_CFG}
  perl -p -i -e "s/#?influxdb_db =.*/influxdb_db = ${INFLUXDB_ENV_PRE_CREATE_DB:-grafana}/g" ${GRAPHIOS_CFG}
fi

if [ ${INFLUXDB_ENV_SSL_SUPPORT} != "**False**" ]; then
  perl -p -i -e "s/#?influxdb_use_ssl =.*/influxdb_use_ssl = True/g" ${GRAPHIOS_CFG} 
fi

exec runsvdir /etc/sv

/etc/init.d/apache2 start
/etc/init.d/graphios start
