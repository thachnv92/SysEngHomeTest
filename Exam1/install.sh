#!/bin/bash

function print_usage_and_exit {
  echo "Usage: "$0" [newaccount] [newhostname]"
  echo "Note: Need to use root account"
  echo ""
  echo "OPTION:"
  echo " newaccount: new system engineer account which you want to create"
  echo " newhostname: new hostname which you want to change"
  echo ""
  echo "Example:"
  echo "  $0 tiki_infra jumphost"
  echo "  $0 tiki_sys was"
  echo "  $0 tiki_secu db-instance"
}

if [ $# -lt 1 ] || [ $# -gt 3 ] ; then
  print_usage_and_exit;
fi

sysengacc=$1
newhostname=$2

#Create sysadmin engineer account
useradd -s /bin/bash -d /home/"$sysengacc" -m -G sudo $sysengacc

#Delete ubuntu account for security
deluser --remove-home ubuntu


#Configure hostname
oldhostname=$(cat /etc/hostname)

sed -i "s/$oldhostname/$newhostname/g" /etc/hosts
sed -i "s/$oldhostname/$newhostname/g" /etc/hostname

hostname -b -F /etc/hostname

#Add alias
echo "alias ls='ls --color=auto'" >> /home/user/.bashrc
echo "alias ll='ls -al'" >> /home/user/.bashrc
echo "alias grep='grep --color=auto'" >> /home/user/.bashrc

source /home/user/.bashrc

#Install docker daemon
curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sh /tmp/get-docker.sh

usermod -aG docker $sysengacc

#Specify logging driver + storage driver of your choice
touch /etc/docker/daemon.json
cat << EOF > /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3",
    "labels": "production_status",
    "env": "prod"
  }
}
EOF

#Tuned for hight network traffic workload
cat << EOF >> /etc/sysctl.conf
# allow testing with buffers up to 64MB 
net.core.rmem_default = 67108864 
net.core.wmem_default = 67108864 
net.core.rmem_max = 67108864 
net.core.wmem_max = 67108864 
# increase Linux autotuning TCP buffer limit to 32MB
sysctl -w net.ipv4.tcp_rmem = 4096 87380 33554432
sysctl -w net.ipv4.tcp_wmem = 4096 65536 33554432
# recommended default congestion control is htcp 
net.ipv4.tcp_congestion_control=htcp
# recommended for hosts with jumbo frames enabled
net.ipv4.tcp_mtu_probing=1
# recommended to enable 'fair queueing'
net.core.default_qdisc = fq
# Maximum pending connections
net.core.somaxconn='4096'
net.core.netdev_max_backlog='4096'
# TCP
net.ipv4.tcp_fin_timeout='15'
net.ipv4.ip_local_port_range='1024 65000'
net.ipv4.tcp_tw_reuse='1'
net.ipv4.tcp_max_syn_backlog='20480'
net.ipv4.tcp_max_tw_buckets='400000'
net.ipv4.tcp_no_metrics_save='1'
net.ipv4.tcp_syn_retries='2'
net.ipv4.tcp_synack_retries='2'
# Increase open files
fs.file-max=65536
EOF

# Increase the File Descriptor Limit
cat << EOF >> /etc/security/limits.conf
* soft     nproc          65535
* hard     nproc          65535
* soft     nofile         65535
* hard     nofile         65535
EOF

echo "session required /lib/security/pam_limits.so" >> /etc/pam.d/login
echo 65535 > /proc/sys/fs/file-max
ulimit -n unlimited

sysctl -p

# Change port SSH
sed -i 's/Port 22/Port 2022/g' /etc/ssh/sshd_config

# Permit root login
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

service ssh restart

reboot

