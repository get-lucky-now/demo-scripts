#!/bin/bash

# Создаем директории для интерфейсов
mkdir -p /etc/net/ifaces/{ens19,ens20}

# Настраиваем интерфейс ens19 (статический IP)
cat <<EOF > /etc/net/ifaces/ens19/options
BOOTPROTO=static
TYPE=eth
EOF

# Настраиваем интерфейс ens20 (статический IP)
cat <<EOF > /etc/net/ifaces/ens20/options
BOOTPROTO=static
TYPE=eth
EOF

# Устанавливаем статические адреса для интерфейсов
echo '172.16.4.1/28' > /etc/net/ifaces/ens19/ipv4address
echo '172.16.5.1/28' > /etc/net/ifaces/ens20/ipv4address

# Включаем форвардинг пакетов
#cat <<EOF > /etc/net/sysctl.conf
#net.ipv4.ip_forward = 1
#net.ipv4.conf.default.rp_filter = 1
#net.ipv4.icmp_echo_ignore_broadcasts = 1
#net.ipv4.tcp_syncookies = 1
#net.ipv4.tcp_timestamps = 0
#EOF

# Включаем форвардинг пакетов
sed -i 's/net.ipv4.ip_forward.*/net.ipv4.ip_forward = 1/' /etc/net/sysctl.conf

sysctl -p

# Очищаем существующие правила iptables и настраиваем NAT
iptables -F
iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
iptables-save > /etc/sysconfig/iptables

# Перезапускаем сеть
service network restart

# Добавляем IPTABLES в автозапуск
systemctl enable iptables
systemctl start iptables

# Создаем нового пользователя
useradd net_admin

# Устанавливаем пароль для пользователя sshuser
passwd net_admin

# Редактируем файл sudoers, разрешая пользователям группы WHEEL выполнять команды без пароля
echo '%WHEEL_USERS ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

# Добавляем пользователя sshuser в группу WHEEL
usermod -aG wheel net_admin

apt-get install frr openssh-server systemd-timesyncd -y

cat <<EOF > /tmp/sshd_new_top
Port 2024
PermitRootLogin no
AllowUsers net_admin
MaxAuthTries 2
Banner /etc/openssh/banner
EOF

cat /etc/openssh/sshd_config >> /tmp/sshd_new_top
mv /tmp/sshd_new_top /etc/openssh/sshd_config

# Создаем файл баннера входа
cat <<EOF > /etc/openssh/banner
Authorized access only

EOF

# Перезапускаем сервис SSHD
systemctl restart sshd.service

# Включаем форвардинг пакетов
sed -i 'ospfd.*/ospfd=yes/' /etc/frr/daemons

# Переименовываем машину
hostnamectl set-hostname isp.au-team.irpo

systemctl disable --now chronyd

cat <<EOF > /etc/systemd/timesyncd.conf
NTP=172.16.4.2
EOF

systemctl enable --now systemd-timesyncd
systemctl restart systemd-timesyncd

# Перезагружаем машину
reboot
