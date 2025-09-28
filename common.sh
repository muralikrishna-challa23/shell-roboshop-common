#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME="$(echo $0 | cut -d '.' -f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_PATH=$PWD
START_TIME=$(date +%s)
MONGODB_HOST=mongo.mkreddy.shop

mkdir -p $LOG_FOLDER

echo -e "Script started executing at: $(date)" | tee -a $LOG_FILE

check_root() {
    if [ $USERID -ne 0 ]; then
        echo -e "ERROR::Please run this with root ccess" | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE() {
if [ $1 -ne 0 ]; then
    echo -e "ERROR::  $2 ....$R FAILURE $W" | tee -a $LOG_FILE
    exit 1
 else
    echo -e " $2 .....$G SUCCESS $W"    | tee -a $LOG_FILE
 fi
}

nodejs_setup(){
   dnf module disable nodejs -y &>>$LOG_FILE
   VALIDATE $? "Disable NodeJs"

   dnf module enable nodejs:20 -y &>>$LOG_FILE
   VALIDATE $? "Enable NodeJs 20"

   dnf install nodejs -y &>>$LOG_FILE
   VALIDATE $? "Installing NodeJs" 

   npm install  &>>$LOG_FILE
   VALIDATE $? "Install dependencies"

}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing Python"

    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "install dependencies"

}

java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven and Java"

    mvn clean package &>>$LOG_FILE
    VALIDATE $? "cleanup package"

    mv /app/target/$APP_NAME-1.0.jar /app/$APP_NAME.jar &>>$LOG_FILE
    VALIDATE $? "move $APP_NAME.jar to app directory "
}

app_user_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating System user roboshop"
    else
        echo -e "User already exists...$Y SKIPPING $W" | tee -a &>>$LOG_FILE
    fi
}

app_setup(){
    mkdir -p  /app &>>$LOG_FILE

    rm -rf /tmp/$APP_NAME.zip &>>$LOG_FILE
    VALIDATE $? "tmp directory $APP_NAME.zip file cleanup"

    curl -o /tmp/$APP_NAME.zip https://roboshop-artifacts.s3.amazonaws.com/$APP_NAME-v3.zip  &>>$LOG_FILE
    VALIDATE $? "Downloading $APP_NAME to /tmp directory"

    cd /app &>>$LOG_FILE
    VALIDATE $? "Moving to app directory"

    rm -rf /app/* &>>$LOG_FILE
    VALIDATE $? "cleanup app directory"

    unzip /tmp/$APP_NAME.zip &>>$LOG_FILE
    VALIDATE $? "unzipping $APP_NAME to app directory"
}

systemd_setup(){
    
    cp $SCRIPT_PATH/$APP_NAME.service  /etc/systemd/system/$APP_NAME.service &>>$LOG_FILE

    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "daemon-reload"

    systemctl enable $APP_NAME &>>$LOG_FILE
    VALIDATE $? "Enabling Catalogue"

    systemctl start $APP_NAME &>>$LOG_FILE
    VALIDATE $? "Starting $APP_NAME"
}

print_tot_time(){
    END_TIME=$(date +%s)
    TOT_TIME=$(($END_TIME-$START_TIME))
    echo -e "Script executed in $G $TOT_TIME seconds $W" 
}