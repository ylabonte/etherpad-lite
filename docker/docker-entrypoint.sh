#!/bin/bash

set -e
if [ ! -z "${MYSQL_HOST}" ] &&\
    [ ! -z "${MYSQL_USER}" ] &&\
    [ ! -z "${MYSQL_PASSWORD}" ] &&\
    [ ! -z "${MYSQL_DATABASE}" ]
then
    export EP_DB_TYPE="mysql"
else
    export EP_DB_TYPE="dirty"
fi

if [ "$1" = "start" ]
then
    cd /app
    ./bin/prepareSettings.sh settings.json.docker settings.json
    if [ "${EP_DB_TYPE}" == "mysql" ]
    then
        # Wait for MySQL
        until mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e"quit" ${MYSQL_DATABASE} &>/dev/null; do :; done
        # In combination with docker-compose, the MySQL container may restart
        # the service on first boot, when it has finished initial setup. The
        # moment between setup and restart will cause the end of the until loop 
        # above to. That's why we sleep 10 seconds...
        sleep 5s
        # ...and then again start waiting for the MySQL service.
        until mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e"quit" ${MYSQL_DATABASE} &>/dev/null; do :; done
    fi
    exec node /app/node_modules/ep_etherpad-lite/node/server.js
fi

exec "$@"
