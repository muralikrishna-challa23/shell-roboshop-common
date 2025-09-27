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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven and Java"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating System user roboshop"
else
    echo -e "User already exists...$Y SKIPPING $W" | tee -a &>>$LOG_FILE
fi

mkdir -p  /app &>>$LOG_FILE

rm -rf /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "tmp directory shipping.zip file cleanup"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading shipping to /tmp directory"

cd /app &>>$LOG_FILE
VALIDATE $? "Moving to app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "cleanup app directory"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzipping shipping to app directory"


mvn clean package &>>$LOG_FILE
VALIDATE $? "cleanup package"

mv /app/target/shipping-1.0.jar /app/shipping.jar &>>$LOG_FILE
VALIDATE $? "move shipping.jar to app directory "


cp $SCRIPT_PATH/shipping.service  /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "Creating shipping service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon-reload"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "Starting shipping"


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

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restarting Shipping"


