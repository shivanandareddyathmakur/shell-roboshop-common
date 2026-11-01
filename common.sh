#!/bin/bash ---- ##shibang

USERID=$( id -u )
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop-common"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.reddy25.shop
MYSQL_HOST=mysql.reddy25.shop

mkdir -p $LOGS_FOLDER
echo "script started executed at: $(date)" | tee -a $LOG_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
        echo "ERROR ... please run with root access"
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}


nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "disabling nodejs"
    dnf module enable nodejs:20 -y   &>>$LOG_FILE
    VALIDATE $? "enabling nodejs 20"
    dnf module install nodejs &>>$LOG_FILE
    VALIDATE $? "installing nodejs 20"
    npm install   &>>$LOG_FILE
    VALIDATE $? "installing dependencies"
}

java_setup(){
    dnf install maven -y   &>>$LOG_FILE
    VALIDATE $? "installing maven (java)"
    mvn clean package     &>>$LOG_FILE
    VALIDATE $? "packing the application"
    mv target/shipping-1.0.jar shipping.jar     &>>$LOG_FILE
    VALIDATE $? "renaming the artifact"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "installing python3"
    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "installing dependencies"
}

app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOG_FILE
        VALIDATE $? "creating system user"
    else
        echo -e "user already exists ... $Y SKIPPING $N"
    fi
    mkdir -p /app
    VALIDATE $? "creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name application"

    cd /app
    VALIDATE $? "moving to app directory"

    rm -rm /app/*
    VALIDATE $? "removing existing code"

    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "unzipped $app_name"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "copy systemctl service"

    systemctl daemon-reload
    systemctl enable $app_name  &>>$LOG_FILE
    VALIDATE $? "enabling $app_name"
}

app_restart(){
    systemctl restart $app_name
    VALIDATE $? "restarting $app_name.service"
}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "script executed in $Y $TOTAL_TIME $N seconds"
}

