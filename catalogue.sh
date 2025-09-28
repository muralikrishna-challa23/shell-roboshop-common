#!/bin/bash

source ./common.sh
APP_NAME ="catalogue"

check_root
app_user_setup
app_setup
nodejs_setup

cp $SCRIPT_PATH/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "mongodb repo copy"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb client"

MONGODATA=$(mongosh mongo.mkreddy.shop --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')" )
if [ $MONGODATA -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load master data to mongodb"
else
  echo -e "Master data already loaded.. $Y SKIPPING $W"
fi

systemd_setup

print_tot_time


