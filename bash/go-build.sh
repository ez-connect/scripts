#!/bin/bash
#
# Build server for linux amd64.
# Usage: ./go_build.sh [name] [build_dir] [platform] [arch] [configs_dir]
#

# Default parameters
appName=app     # The app name
buildDir=build  # The output build
platform=linux
arch=amd64
configsDir=

# Read arguments
if [ ! -z "$1" ]; then
  appName=$1
fi

if [ ! -z "$2" ]; then
  buildDir=$2
fi

if [ ! -z "$3" ]; then
  platform=$3
fi

if [ ! -z "$4" ]; then
  arch=$4
fi

if [ ! -z "$5" ]; then
  configsDir=$5
fi

# Print parameters
printf "App name:\t${appName}\n"
printf "Build dir:\t${buildDir}\n"
printf "Platform:\t${platform}\n"
printf "Arch:\t\t${arch}\n"
printf "Config dir:\t\t${configsDir}\n"

# Clean build
if [ -d ${buildDir} ]; then
  rm -rf ${buildDir}
fi

# Set go variables
GOOS=${platform}
GOARCH=${arch}

# Build
go build -ldflags="-s -w" -o "${buildDir}/${appName}-${platform}-${arch}"

# Copy configs
if [ ! -z "${configsDir}" ]; then
  cp -r "${configsDir}/" "${buildDir}/configs/"
fi
