#!/bin/bash

source ./common.sh
app_name=redis

check_root

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "disabling nodejs"
dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "enabling redis 7"
dnf install redis -y &>>$LOG_FILE
VALIDATE $? "installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "allowing remote connections to redis"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "enabling redis"

systemctl start redis
VALIDATE $? "starting redis"

print_total_time
