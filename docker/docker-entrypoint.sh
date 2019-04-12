#!/bin/sh

set -e
if [ ! -z "$EP_MYSQL_HOST" ]\
&& [ ! -z "$EP_MYSQL_USER" ]\
&& [ ! -z "$EP_MYSQL_PASSWORD" ]\
&& [ ! -z "$EP_MYSQL_DATABASE" ]
then
    export EP_DB_TYPE="mysql"
else
    export EP_DB_TYPE="dirty"
fi

if [ "$1" = "start" ]
then
    cd /app
    ./bin/prepareSettings.sh settings.json.docker settings.json
    COUNTER=0
    if [ "$EP_DB_TYPE" = "mysql" ]
    then
        printf "Waiting for the mysql service"
        # Wait for MySQL
        until mysql -h$EP_MYSQL_HOST -u$EP_MYSQL_USER -p$EP_MYSQL_PASSWORD -equit $EP_MYSQL_DATABASE 2>/dev/null && [ 0 -eq $? ] || [ $COUNTER -ge 20 ]
        do
            sleep 3s
            printf "."
        done
        if [ $COUNTER -ge 20 ]
        then
            printf "\nService not responding!"
            exit 1
        else
            # In combination with docker-compose, the MySQL container may restart
            # the service on first boot, when it has finished initial setup. The
            # moment between setup and restart will cause the end of the until loop 
            # above to. That's why we sleep 10 seconds...
            sleep 5s
            printf "\nService connection successful!\nNow waiting for a restart of the mysql service"
            # ...and then again start waiting for the MySQL service.
            COUNTER=0
            until mysql -h$EP_MYSQL_HOST -u$EP_MYSQL_USER -p$EP_MYSQL_PASSWORD -equit $EP_MYSQL_DATABASE 2>/dev/null && [ 0 -eq $? ] || [ $COUNTER -ge 10 ]
            do
                sleep 3s
                printf "."
            done
            printf "\nOK!"
        fi
    fi
    exec node /app/node_modules/ep_etherpad-lite/node/server.js
fi

exec "$@"
