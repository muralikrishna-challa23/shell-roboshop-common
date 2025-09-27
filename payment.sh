#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME="$(echo $0 | cut -d '.' -f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOG_FOLDER
echo -e "Script started executing at: $(date)" | tee -a $LOG_FILE

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

SCRIPT_PATH=$PWD

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing Python"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating System user roboshop"
else
    echo -e "User already exists...$Y SKIPPING $W" | tee -a &>>$LOG_FILE
fi

mkdir -p  /app &>>$LOG_FILE

rm -rf /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "tmp directory payment.zip file cleanup"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading payment to /tmp directory"

cd /app &>>$LOG_FILE
VALIDATE $? "Moving to app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "cleanup app directory"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzipping payment to app directory"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "install dependencies"

cp $SCRIPT_PATH/payment.service  /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "Creating Payment service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon-reload"

systemctl enable payment &>>$LOG_FILE
VALIDATE $? "Enabling payment"

systemctl start payment &>>$LOG_FILE
VALIDATE $? "Starting payment"
