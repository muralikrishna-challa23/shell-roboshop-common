#!/bin/bash

source ./common.sh

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

print_tot_time
