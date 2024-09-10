#!/bin/bash
export CRIO_VERSION=v1.29

apt-get update
apt-get install -y software-properties-common curl
apt-get install -y linux-headers-$(uname -r)

curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/cri-o.list

apt-get update
apt-get install -y cri-o

systemctl start crio.service

swapoff -a
modprobe br_netfilter
sysctl -w net.ipv4.ip_forward=1

touch /tmp/signal