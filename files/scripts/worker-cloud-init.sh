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

apt-get install -y conmon

wget https://downloads.nestybox.com/sysbox/releases/v0.6.4/sysbox-ce_0.6.4-0.linux_amd64.deb
sudo apt-get install jq
sudo apt-get install ./sysbox-ce_0.6.4-0.linux_amd64.deb

sudo adduser containers

cat <<EOF > /etc/subuid
debian:100000:65536
sysbox:165536:65536
containers:231072:16777216
EOF

cat <<EOF > /etc/subgid
debian:100000:65536
sysbox:165536:65536
containers:231072:16777216
EOF

cat <<EOF > /etc/crio/crio.conf
[crio.runtime.runtimes.sysbox-runc]
allowed_annotations = ["io.kubernetes.cri-o.userns-mode"]
runtime_path = "/usr/bin/sysbox-runc"
runtime_type = "oci"
EOF

touch /tmp/signal
