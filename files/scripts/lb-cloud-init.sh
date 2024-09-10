#!/bin/bash
export HAPROXY_VERSION=lts

# Add Docker's official GPG key:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

cat << EOF > /home/debian/docker-compose.yml
name: haproxy
services:
  lb:
    image: haproxy:lts
    container_name: haproxy
    network_mode: host
    volumes:
        - /etc/haproxy:/usr/local/etc/haproxy:ro
EOF

docker compose -f /home/debian/docker-compose.yml up -d

touch /tmp/signal