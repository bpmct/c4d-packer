#!/bin/sh

sed -e 's|DEFAULT_FORWARD_POLICY=.*|DEFAULT_FORWARD_POLICY="ACCEPT"|g' \
    -i /etc/default/ufw

ufw limit ssh
ufw allow 2375/tcp
ufw allow 2376/tcp

ufw allow 80/tcp
ufw allow 443/tcp

# allow workspace containers to access coder over HTTP
# however, 7080 is limited to the docker network interface
# in docker-compose.yaml
ufw allow 7080/tcp

ufw --force enable
