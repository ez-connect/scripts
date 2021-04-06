#!/bin/bash
#
# Build a Golang application
#

# Constants
OUTPUT_DIR='public' # default build dir
PLATFORM='linux'
ARCH='amd64'

# Help
function help() {
  echo 'Usage: ./go-build.sh [OPTION]... [NAME]'
  echo 'Build a Golang application'
  echo
  echo 'Options:'
  echo -e '  -o, --output \t output dir, default `build`'
  echo -e '  -p, --platform \t platform target, default `linux`'
  echo -e '  -a, --arch \t arch target, default `amd64`'
  echo -e '  -h, --help \t print this help'
}

# Loop through arguments and process them
for arg in "$@"
do
  case $arg in
    -o=*|--output=*)
      OUTPUT_DIR="${arg#*=}"
      shift;;

    -p=*|--platform=*)
      PLATFORM="${arg#*=}"
      shift;;

    -a=*|--arch=*)
      ARCH="${arg#*=}"
      shift;;

    -h|--help)
      help
      exit;;
  esac
done

# Require name arg
if [ -z "$1" ]; then
  help
  exit 1
fi

# Application name
name=$1

echo "Build ${name}-${PLATFORM}-${ARCH}"

# Clean build
if [ -d "${OUTPUT_DIR}" ]; then
  rm -rf "${OUTPUT_DIR}"
fi

# Set go variables
GOOS=${PLATFORM}
GOARCH=${ARCH}

# Build
go build -ldflags="-s -w" -o "${OUTPUT_DIR}/${name}-${PLATFORM}-${ARCH}"
