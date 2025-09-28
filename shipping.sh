#!/bin/bash

source ./common.sh
APP_NAME="shipping"

check_root

app_user_setup

app_setup

java_setup

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql client"

mysql -h mysql.mkreddy.shop -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h mysql.mkreddy.shop -uroot -pRoboShop@1 < /app/db/schema.sql  &>>$LOG_FILE
    mysql -h mysql.mkreddy.shop -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h mysql.mkreddy.shop -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
else
   echo -e "Mysql data already loaded...$G SKIPPING  $W"
fi

systemd_setup

print_tot_time
