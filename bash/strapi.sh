#!/bin/bash
#
# Strapi helper
#

# Help
function help() {
  echo 'Usage: ./strapi.sh [OPTION]... URL'
  echo 'Strapi helper'
  echo
  echo 'Options:'
  echo -e '  -o, --output \t output dir, default `build`'
  echo -e '  -p, --platform \t platform target, default `linux`'
  echo -e '  -a, --arch \t arch target, default `amd64`'
  echo -e '  -h, --help \t print this help'
}
