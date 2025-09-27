#!/bin/bash

source ./common.sh

check_root


cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE
VALIDATE $? "Copy Mongo.repo file"

dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? "Installing monodb"


systemctl enable mongod &>> $LOG_FILE
VALIDATE $? "Enabling mongodb"

systemctl start mongod &>> $LOG_FILE
VALIDATE $? "Starting Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOG_FILE
VALIDATE $? "Allowing Remote Connections"

systemctl restart mongod &>> $LOG_FILE
VALIDATE $? "Restart mongodb"

print_tot_time