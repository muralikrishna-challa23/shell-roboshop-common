#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME="$(echo $0 | cut -d '.' -f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)

mkdir -p $LOG_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo -e "ERROR::Please run this with root ccess" | tee -a $LOG_FILE
    exit 1
 fi

VALIDATE() {
if [ $1 -ne 0 ]; then
    echo -e "ERROR::  $2 ....$R FAILURE $W" | tee -a $LOG_FILE
    exit 1
 else
    echo -e " $2 .....$G SUCCESS $W"    | tee -a $LOG_FILE
 fi
}


cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $LOG_FILE
VALIDATE $? "Copy rabbitmq.repo file"


dnf install rabbitmq-server -y &>> $LOG_FILE
VALIDATE $? "Installing rabbitmq"

systemctl enable rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Enabling rabbitmq"

systemctl start rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $LOG_FILE
VALIDATE $? "Adding roboshop user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG_FILE
VALIDATE $? "setting permissions to roboshop user"

END_TIME=$(date +%s)
TOT_TIME=$(($END_TIME-$START_TIME))

echo -e "Script executed in $G $TOT_TIME seconds $W"
