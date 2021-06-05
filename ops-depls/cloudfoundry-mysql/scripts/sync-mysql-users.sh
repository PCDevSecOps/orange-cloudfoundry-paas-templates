#!/bin/bash

# This script sync users between 2 galera cluster memebers
# Usefull when a user has been created inserting in the mysql database
# As mysql database storage engine is MyISAM, it's not sync withe galera 

if [ $# -eq 0 ]
  then
    echo "Usage: $0 <mysql root password>"
    exit 1
fi

mysql --silent -uroot -p$1 -h192.168.30.149 < gen-cf-users.sql > cf-users.sql
if [ $? -ne 0 ]; then
  echo "[ERROR] An error occured, while generating user list, you should inspect"
  exit 1
fi

mysql  -uroot -p$1 -h192.168.30.156 < cf-users.sql
if [ $? -ne 0 ]; then
  echo "[ERROR] An error occured, while creating users, you should inspect"
  exit 1
fi

echo "[SUCCESS] All users have been synced"

