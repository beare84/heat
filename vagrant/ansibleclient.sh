#!/bin/bash

# Security Related
/usr/sbin/setenforce 1
/usr/bin/firewall-cmd --permanent --zone=public --add-port=22/tcp
/usr/sbin/usermod root --password '$6$m6GqgmWQWbFn$slSfY7IMHSIiMT1nOlMPLEgkvnMO2L3vJV0Oq8.14R570e/YgrW1YQp2xVt0drtYjrgA.iafmTOPH7gPFpf5G0'

# Enable Services
/usr/bin/systemctl enable --now firewalld

# Set timezone
/usr/bin/timedatectl set-timezone Australia/Sydney

# Set hostname
/usr/bin/hostname ansibleclient
/usr/bin/echo -e "ansibleclient" >> /etc/hostname

# Enable services
/usr/bin/systemctl enable --now sshd

# Ansible config
useradd ansible
/usr/sbin/usermod ansible --password '$6$m6GqgmWQWbFn$slSfY7IMHSIiMT1nOlMPLEgkvnMO2L3vJV0Oq8.14R570e/YgrW1YQp2xVt0drtYjrgA.iafmTOPH7gPFpf5G0'
/usr/bin/echo "ansible ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/ansible

# Update System
/usr/bin/dnf update -y

# Cleanup
/usr/bin/rm -f /tmp/firstboot.exec

# Restart
/usr/sbin/reboot now