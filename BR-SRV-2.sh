#!/bin/bash

samba-tool domain info 127.0.0.1

# После перезагрузки создаем новых пользователей и групп в AD
samba-tool user add user1.hq P@ssw0rd
samba-tool user add user2.hq P@ssw0rd
samba-tool user add user3.hq P@ssw0rd
samba-tool user add user4.hq P@ssw0rd
samba-tool user add user5.hq P@ssw0rd

samba-tool group add hq
samba-tool group addmembers hq user1.hq,user2.hq,user3.hq,user4.hq,user5.hq

# распаковка юзеров
curl -L https://bit.ly/3C1nEYz > /root/users.zip
unzip /root/users.zip

# запуск скрипта 
csv_file="/root/Users.csv"
while IFS=";" read -r firstName lastName role phone ou street zip city country password; do
	if [ "$firstName" == "First Name" ]; then
		continue
	fi
	username="${firstName,,}.${lastName,,}"
	samba-tool user add "$username" P@ssw0rd;
done < "$csv_file"

# Обновляем систему
apt-get update

