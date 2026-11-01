#!/bin/bash

source ./common.sh

check_root

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Adding rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE "installing rabbitmq server"

systemctl enable rabbitmq-server  &>>$LOG_FILE
VALIDATE $? "enabling rabbitmq-server"
systemctl start rabbitmq-server  &>>$LOG_FILE
VALIDATE "starting rabbitmq-server"
rabbitmqctl add_user roboshop roboshop123  &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "setting up permissions"

print_total_time
