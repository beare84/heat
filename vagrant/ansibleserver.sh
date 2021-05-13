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
/usr/bin/hostname ansibleserver
/usr/bin/echo -e "ansibleserver" >> /etc/hostname

# Install Ansible
yum install epel-release -y
yum install ansible -y

# Enable services
/usr/bin/systemctl enable --now ansible
/usr/bin/systemctl enable --now sshd

# Ansible config
useradd ansible
/usr/sbin/usermod ansible --password '$6$m6GqgmWQWbFn$slSfY7IMHSIiMT1nOlMPLEgkvnMO2L3vJV0Oq8.14R570e/YgrW1YQp2xVt0drtYjrgA.iafmTOPH7gPFpf5G0'
/usr/bin/echo "ansible ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/ansible
mkdir /home/ansible/ansible

# Ansible hosts files
cat <<EOF > /home/ansible/ansible/hosts.txt
[groupa]
agent1 ansible_user=ansible
agent2 ansible_user=ansible

[groupb]
agent3 ansible_user=ansible
agent4 ansible_user=ansible
EOF

# Sample Playbook
cat <<EOF > /home/ansible/ansible/playbook.yaml
  - name: Playbook
    hosts: agent1
    become: yes
    become_user: root
    tasks:
      - name: ensure apache is at the latest version
        yum:
          name: httpd
          state: latest
          #state: absent
      - name: ensure apache is running
        service:
          name: httpd
          state: started
EOF

# Sample Playbook that runs a script on the agent
cat <<EOF > /home/ansible/ansible/script.yaml
  - name: Let's copy our executable script to remote location, execute script and get result back.
    become: yes
    become_user: root
    hosts: agent1
    tasks:
      - name: Transfer executable script script
        copy: src=/home/ansible/ansible/shell-script.sh dest=/home/ansible mode=0777
      - name: Execute the script
        command: sh /home/ansible/shell-script.sh
EOF

# Host file entries
/usr/bin/echo -e "127.0.0.1 agent1" >> /etc/hosts

# Example file
cat <<EOF > /home/ansible/ansible/examples.txt
# Run shell command on agent
ansible -i hosts.txt -b --become-method=sudo -m shell -a 'yum update -y' agent1
# Verbose output
ansible -i hosts.txt -b --become-method=sudo -m shell -a 'yum update -y' agent1 -vvv
# Run playbook against agents
ansible-playbook playbook.yaml -i hosts.txt
EOF

cat <<EOF > /home/ansible/ansible/ssh-keypair-setup.sh
# As ansible user, gen keypair:
ssh-keygen
# Copy key to agent:
ssh-copy-id ansible@agent1
# Enter password to log into agent1
EOF

# Correct perms
chown -R ansible /home/ansible
/usr/bin/chmod +x /home/ansible/ansible/ssh-keypair-setup.sh

# Update System
/usr/bin/dnf update -y

# Cleanup
/usr/bin/rm -f /tmp/firstboot.exec

# Restart
/usr/sbin/reboot now