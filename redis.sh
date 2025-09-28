#!/bin/bash


source ./common.sh

check_root

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disable redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling redis7"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/c  protected-mode no' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "IAllowing Remote connections"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "enabling redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Starting redis"

print_tot_time
