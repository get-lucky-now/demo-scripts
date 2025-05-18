#!/bin/bash

cat <<EOF
На CLI:
apt-get update > apt-get install admc
kinit administrator > P@ssw0rd
admc

Включаем:
Настройки > Дополнительные возможности > au-team.irpo > sudoers > prava_hq > Атрибуты
sudoOption: добавляем !authenticate
sudoCommand: добавляем /bin/grep и /usr/bin/id

apt-get update
apt-get install sudo libsss_sudo
control sudo public

nano /etc/sssd/sssd.conf:
services = nss, pam, sudo
sudo_provider = ad  (после id_provider и перед auth_provider)

nano /etc/nsswitch.conf:
sudoers: files sss  # после gshadow

reboot
rm -rf /var/lib/sssd/db/*
sss_cache -E
systemctl restart sssd

sudo -l -U user1.hq
reboot

Под user1.hq:
sudo cat /etc/passwd | sudo grep root
sudo id root
EOF

#echo "На CLI"
#echo "apt-get update > apt-get install admc > kinit administrator > P@ssw0rd > admc"
#echo "Включаем Настройки > Дополнительные возможности > au-team.irpo > sudoers > prava_hq > Атрибуты"
#echo "sudoOption > добавляем !authenticate"
#echo "sudoCommand добавляем /bin/grep и /usr/bin/id"
#echo "apt-get update > apt-get install sudo libsss_sudo > control sudo public"
#echo "nano /etc/sssd/sssd.conf"
#echo "services = nss, pam, sudo"
#echo "sudo_provider = ad (после id_provider и перед auth_provider)"
#echo "nano /etc/nsswitch.conf"
#echo "sudoers: files sss (после gshadow)"
#echo "reboot > rm -rf /var/lib/sssd/db/* > sss_cache -E > systemctl restart sssd > sudo -l -U user1.hq"
#echo "Под пользователем user1.hq > sudo cat /etc/passwd | sudo grep root > sudo id root"
echo "Возвращаемся на BR-SRV"
read -p "Нажми Enter, чтобы продолжить..."

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

