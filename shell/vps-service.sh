#!/bin/sh
#
# Reload a service on your server
#

# Help
help() {
  echo 'Usage:./vps-service.sh [SERVER] [FILE] [SERVICE]'
  echo 'Reload a service on your server. Make sure the service was registed on your server.'
  echo
  echo 'Example:'
  echo './vps-service.sh name@example.com /path/to/app.service app'
}

# Service name
server="$1"
file="$2"
service="$3"

echo "Restart ${name} service"
ssh $server "chmod +u+x ${file}"
ssh $server "sudo systemctl daemon-reload"
ssh $server "sudo systemctl restart ${service}"
ssh $server "sudo systemctl status ${service}"
