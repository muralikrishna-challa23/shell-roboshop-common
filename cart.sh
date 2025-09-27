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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable NodeJs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable NodeJs 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJs"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating System user roboshop"
else
    echo -e "User already exists...$Y SKIPPING $W" | tee -a &>>$LOG_FILE
fi

mkdir -p  /app &>>$LOG_FILE

rm -rf /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "tmp directory cart.zip file cleanup"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading cart to /tmp directory"

cd /app &>>$LOG_FILE
VALIDATE $? "Moving to app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "cleanup app directory"

unzip /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "unzipping cart to app directory"

npm install  &>>$LOG_FILE

cp $SCRIPT_PATH/cart.service  /etc/systemd/system/cart.service &>>$LOG_FILE

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon-reload"

systemctl enable cart &>>$LOG_FILE
VALIDATE $? "Enabling cart"

systemctl start cart &>>$LOG_FILE
VALIDATE $? "Starting cart"


