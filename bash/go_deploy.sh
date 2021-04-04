#!/bin/bash
#
# Deploy a application to your server
# Usage: ./go_deploy.sh [name] [server] [source] [target]
#     ./go_deploy.sh my-app dev:111.111.111.111 ./build/* /opt/server/my-app
#

# Default
name=app
server=
source=
target=

# Has parameters
if [ ! $# -eq 4 ]; then
  echo "Missing arguments"
  echo "Usage: ./go_deploy.sh [name] [server] [source] [target]"
  exit 1
fi

# Read parameters
if [ ! -z "$1" ]; then
  name="$1"
fi

if [ ! -z "$2" ]; then
  server="$2"
fi

if [ ! -z "$1" ]; then
  source="$3"
fi

if [ ! -z "$4" ]; then
  target="$4"
fi

# Print parameters
printf "Service name:\t${name}\n"
printf "Server:\t${server}\n"
printf "Source:\t${source}\n"
printf "Target:\t${target}\n"

echo 'Copy files to server...'
ssh ${server} "rm -rf ${target} && mkdir ${target}"
scp -r $source $server:$target/

echo "Restart ${name} service"
ssh $server "chmod +u+x ${target}/${name}"
ssh $server "sudo systemctl daemon-reload"
ssh $server "sudo systemctl restart ${name}"
ssh $server "sudo systemctl status ${name}"
