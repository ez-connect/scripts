#!/bin/bash
#
# Deploy your app to a server
#

# Help
function help() {
  echo 'Usage:./vps-deploy.sh [SERVER] [SOURCE] [DESTINATION]'
  echo 'Deploy your app to server'
  echo
  echo 'Example:'
  echo './vps-deploy.sh name@example.com ./path/to/source ./path/to/destination'
}

# Has parameters
if [ ! $# -eq 3 ]; then
  help
  exit 1
fi

# Read parameters
server="$1"
source="$2"
target="$3"

# Print parameters
# echo -e "Server: ${server}"
# echo -e "Source: ${source}"
# echo -e "Target: ${target}"

echo "Copy ${source} to ${target} on ${server}"
ssh ${server} "rm -rf ${target} && mkdir ${target}"
scp -r $source $server:$target/
