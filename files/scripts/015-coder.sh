#!/bin/sh

cd $HOME
git clone https://github.com/bpmct/c4d-packer $HOME/coder/
cd $HOME/coder && INITIAL_PASSWORD=temp_coder12345 docker-compose up -d

# health check: wait for Coder to start running
bash -c 'while [[ "$(curl --insecure -s -o /dev/null -w ''%{http_code}'' https://127.0.0.1/healthz)" != "201" ]]; do sleep 3; done'

# log in using the default user and password
output=$(curl 'https://127.0.0.1/auth/basic/login' \
  --data-raw '{"email":"admin","password":"temp_coder12345"}' \
  --compressed \
  --insecure)

# grab session token
session_token="$(
    echo "$output" | \
    grep "session_token" | \
    sed -e 's/"//g' -e 's/ //g' -e 's/,//g' | \
    cut -d ":" -f2
)"

# change Docker provider access URL to support CVM workspaces
curl --insecure  \
    -i -H "Session-Token: $session_token" \
    -X PUT 'https://127.0.0.1/api/private/workspace-providers/docker' \
    --data-raw '{"name":"Docker","org_whitelist":["default"],"access_url":"http://172.17.0.1:7080","docker":{"api_uri":"unix:///var/run/docker.sock"}}'

# set temporary password instead of the default one
# this will also show the license prompt during initial log in
curl --insecure \
    -i -H "Content-Type: application/json" \
    -H "Session-Token: $session_token" \
    -X PATCH "https://127.0.0.1/api/v0/users/admin" \
    --data '{"old_password":"temp_coder12345","password":"coder12345", "temporary_password": true}'