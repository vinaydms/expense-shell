#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "please enter DB password:"
read -s mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
#     if [ $1 -eq 0 ]
#     then
#         echo -e "$2...$G SUCCESS $N"
#     else
#         echo -e "$2...$R FAILURE $N"
#     fi
}

if [ $USERID -ne 0 ]
then    
    echo "Please run this script with root access."
    exit 1 # manually exit other than zero 
else
    echo "you are super user."
fi
# if [ $USERID -eq 0 ]
# then
#     echo "you are super user."
# fi

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing Mysql Server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling Mysql Server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting Mysql Server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? " Setting Root Password" 

#Below code will be useful for idempotent nature
#mysql -h db.devopsvinay.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
mysql -uroot -p${mysql_root_password} -e "show databases;"
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "MySQL Root Password Setup"
else
    echo -e "MySQL Root Password is already setup...$Y SKIPPING $N"
fi
