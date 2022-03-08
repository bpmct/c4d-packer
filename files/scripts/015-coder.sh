#!/bin/sh

cd $HOME
git clone https://github.com/bpmct/c4d-packer $HOME/coder/
cd $HOME/coder && INITIAL_PASSWORD=temp1_coder12345 docker-compose up -d

health_check() {
    echo "Waiting for Coder to be ready..."
    bash -c 'while [[ "$(curl --insecure -s -o /dev/null -w ''%{http_code}'' https://127.0.0.1/healthz)" != "200" ]]; do sleep 3; done'
}

# restart to apply password to DB
health_check
docker-compose down
docker-compose up -d
health_check

# log in using the default user and password
output=$(curl 'https://127.0.0.1/auth/basic/login' \
  --data-raw '{"email":"admin","password":"temp1_coder12345"}' \
  --compressed \
  --insecure)

# grab session token
session_token="$(
    echo "$output" | \
    grep "session_token" | \
    sed -e 's/"//g' -e 's/ //g' -e 's/,//g' | \
    cut -d ":" -f2
)"

# set a non-temporary password in order to modify some 
# deployment settings 
curl --verbose --insecure \
    -i -H "Content-Type: application/json" \
    -H "Session-Token: $session_token" \
    -X PATCH "https://127.0.0.1/api/v0/users/me" \
    --data '{"old_password":"temp1_coder12345","password":"temp2_coder12345", "temporary_password": false}'

# change Docker provider access URL
# this is a workaround to support CVM workspaces
# with self-signed certificates
curl --verbose --insecure  \
    -i -H "Session-Token: $session_token" \
    -X PUT 'https://127.0.0.1/api/private/workspace-providers/docker' \
    --data-raw '{"name":"Docker","org_whitelist":["default"],"access_url":"http://host.docker.internal:7080","docker":{"api_uri":"unix:///var/run/docker.sock"}}'

# revert to "temporary" password instead of the default one
# this is also necessary to show the setup/generate license prompt
# during initial log in
curl --verbose --insecure \
    -i -H "Content-Type: application/json" \
    -H "Session-Token: $session_token" \
    -X PATCH "https://127.0.0.1/api/v0/users/me" \
    --data '{"old_password":"temp2_coder12345","password":"coder12345", "temporary_password": true}'

# restart one final time to be safe
docker-compose down
docker-compose up -d
